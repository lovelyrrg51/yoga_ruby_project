# frozen_string_literal: true
class GenerateExcel

  def self.generate options = {}
    options[:data_type] ||= 'string'
    options[:header] ||= []
    options[:rows] ||= []

    spreadsheet = Spreadsheet::Workbook.new
    report = spreadsheet.create_worksheet(name: 'List of members')

    options[:header].each do |column|
      report.row(0).concat %W{#{column}}
    end

    options[:rows].each_with_index do |reg , i|
      (0..options[:header].length).each do |col|
        report.row(i+1).push reg[col]
      end
    end

    header_format = Spreadsheet::Format.new(color: 'red', weight: 'bold')
    report.row(0).default_format = header_format

    blob = if options[:data_type] == 'string'
      StringIO.new()
    else
      Tempfile.new([Random.new_seed.to_s, '.xls'], "#{Rails.root}/tmp")
    end
    spreadsheet.write blob

    options[:data_type] == 'string' ? blob.string : blob
  end

  def self.generate_and_upload options = {}
    file = generate(rows: options[:rows], header: options[:header], data_type: 'file')

    result = s3_file_upload(options.merge({content: file, file_type: 'application/vnd.ms-excel'}))

    # Remove temp file
    begin
      file.close(true)
    rescue => e
      Rollbar.error(e)
      Rails.logger.info(e.backtrace)
    end

    result
  end

  private

  # file_name, file_path, content, bucket_name, is_secure, file_type, prefix
  def self.s3_file_upload options = {}
    # Set default options
    acl = options[:is_secure] == false ? 'public-read' : 'private'
    options[:bucket_name] ||= ENV['ATTACHMENT_BUCKET']

    raise 'No options for file upload.' unless options.present?

    # Access Bucket
    bucket = Aws::S3::Bucket.new(options[:bucket_name])
    raise 'Bucket not found error.' unless bucket.exists?

    # Genearte s3 file path
    s3_file_path = options[:prefix].present? ? "#{options[:prefix]}/#{Time.now.to_i}-#{options[:file_name]}" : "#{Time.now.to_i}-#{options[:file_name]}"

    # Upload file to s3
    s3_file = bucket.put_object(acl: acl, body: options[:content], content_type: options[:file_type], key: s3_file_path)

    raise 'Something went wrong while uploading file. Please try again.' unless s3_file.exists?

    s3_file.exists? ? s3_file : nil
  end

end
