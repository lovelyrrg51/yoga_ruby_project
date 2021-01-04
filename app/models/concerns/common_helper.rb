module CommonHelper
  extend ActiveSupport::Concern

  included do
    def self.generate_excel_and_upload(options = {})
      GenerateExcel.generate_and_upload options
    end

    def email_async(options = {})
      ApplicationMailer.send_email(options).deliver
    end
    handle_asynchronously :email_async
  end

  class Global
    include Singleton
  end

  class ::Hash

    def method_missing(name)
      return self[name] if key? name
      self.each { |k,v| return v if k.to_s.to_sym == name }
      super.method_missing name
    end

  end

  class ::Array

    # Check wether all emails are valid or not?
    def is_valid_emails?
      extract_valid_emails.size == count
    end

    # Returns valid emails - Return::Type::Array
    def extract_valid_emails
      reject(&:blank?).select { |e| e =~ Devise::email_regexp }
    end
  end

  require "zlib"
  require 'base64'

  class ::String
    def is_valid_email?
      self.split(',').map(&:strip).is_valid_emails?
    end

    def extract_valid_emails
      self.split(',').map(&:strip).extract_valid_emails
    end

    # Compress a string
    def compress
      compressed_data = Zlib::Deflate.deflate(self)
      Base64.encode64 compressed_data
    end

    # Decompress a string
    def decompress
      decoded_data = Base64.decode64(self)
      Zlib::Inflate.inflate(decoded_data)
    end

    def encrypt(key = Rails.application.secrets.secret_key_base)
      crypto = Crypto.new
      crypto.encrypt(self, key)
    end

    def decrypt(key = Rails.application.secrets.secret_key_base)
      crypto = Crypto.new
      crypto.decrypt(self, key)
    end

    def rnd(precision = 2)
      to_f.to_d.truncate(2).to_f
    end

    def to_bool
      return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
      return false if self == false || self.empty? || self =~ (/(false|f|no|n|0)$/i)
    end

  end

  class ::Numeric
    def rnd(precision = 2)
      to_f.to_d.truncate(2).to_f
    end
  end

  class ::NilClass
    def rnd(precision = 2)
      to_f.rnd
    end

    def to_bool
      false
    end
  end

  class SyException < StandardError
  end

  def s3_downloadable_url(options = {})
    # bucket_name, s3_file_path

    # Set default options
    options[:expires] ||= 7200
    options[:is_secure] ||= true
    options[:use_ssl] ||= true
    options[:virtual_host] = !options[:virtual_host] ? false : true
    options[:method] = (options[:method].is_a?(String) ? options[:method].try(:to_sym) : options[:method]) || :get

    if self.is_a?(Attachment)
      options[:bucket_name] = self.s3_bucket
      options[:s3_file_path] = self.s3_path
    end

    # Raise error if needed parameters are not recieved
    raise SyException.new("Options cannot be blank.") unless options.present?
    raise SyException.new("Bucket name cannot be blank.") unless options[:bucket_name].present?
    raise SyException.new("S3_path cannot be blank.") unless options[:s3_file_path].present?

    # Access bucket
    bucket = Aws::S3::Bucket.new(options[:bucket_name])
    raise SyException.new("No bucket found.") unless bucket.exists?

    # Get s3 file
    s3_file = bucket.object(options[:s3_file_path])
    raise SyException.new("No s3 file found.") unless s3_file.exists?

    # Generate URL
    url = s3_file.presigned_url(options[:method], secure: options[:is_secure], expires_in: options[:expires].try(:to_i), virtual_host: options[:virtual_host]).to_s

    url
  end

  require 'spreadsheet'
  require 'csv'
  require 'roo'
  def validate_file_type(file, file_name)
    case File.extname(file_name)
    when '.csv'
      read_csv(file.path)
    when '.xls'
      read_xls(file.path)
    when '.xlsx'
      read_xlsx(file.path)
    when '.pdf'
      read_pdf(file.path)
    else
      raise SyException.new("Unknown file type: #{file_name}")
    end
  end

  def read_csv(file)
    content = []
    header = []
    begin
      CSV.foreach(file, headers: true, skip_blanks: true, encoding: 'ISO-8859-1', return_headers: true, header_converters: :downcase) do |row|
        header = row.headers if row.header_row?
        if row.field_row?
          _row = Hash[row.to_a].deep_symbolize_keys
          next if _row.values.all?(&:blank?)
          content.push(_row)
        end
      end
    rescue Exception => e
      Rails.logger.info("Actual error while reading CSV: #{e.message}")
      Rails.logger.info(e.backtrace.inspect)
      raise SyException, "Either uploaded file is corrupted or data inside file corrupted. Please input a valid file."
    end
    {
      content: content,
      header: header
    }
  end

  def read_xlsx(file)
    content = []
    begin
      spreadsheet = Roo::Spreadsheet.open(file, extension: :xlsx)
      header = (spreadsheet.row(1) - [nil]).map(&:downcase)
      (2..spreadsheet.last_row).each do |i|
        row = (Hash[[header, spreadsheet.row(i)[0...header.count]].transpose]).deep_symbolize_keys
        next if row.values.all?(&:blank?)
        content.push(row)
      end
    rescue Exception => e
      Rails.logger.info("Actual error while reading XLSX: #{e.message}")
      Rails.logger.info(e.backtrace.inspect)
      raise SyException, "Either uploaded file is corrupted or data inside file corrupted. Please input a valid file."
    end
    return {content: content, header: header}
  end

  def read_xls(file)
    content = []
    begin
      book = Spreadsheet.open(file)
      sheet = book.worksheet 0
      header = (sheet.row(0) - [nil]).map(&:downcase)
      sheet.each 1 do |row|
        _row = (Hash[[header, row[0...header.count]].transpose]).deep_symbolize_keys
        next if _row.values.all?(&:blank?)
        content.push(_row)
      end
    rescue Exception => e
      Rails.logger.info("Actual error while reading XLS: #{e.message}")
      Rails.logger.info(e.backtrace.inspect)
      raise SyException, "Either uploaded file is corrupted or data inside file corrupted. Please input a valid file."
    end
    return {content: content, header: header}
  end

  def read_pdf(file)
    is_saved = false
    pdf = Grim.reap(file)
    tmp_file_name = "#{Rails.root}/tmp/#{Random.new_seed.to_s}.png"
    if pdf.count > 0
      is_saved = pdf[0].save(tmp_file_name, {quality: 20, density: 100, width: 600})
    end
    raise 'Unable to save pdf to png converted file.' unless is_saved
    tmp_file_name
  end

  def generate_excel_and_upload(options = {})
    self.class.generate_excel_and_upload(options)
  end

  def generate_pdf(type, data, file_name)
    html = ActionController::Base.new.render_to_string(template: "#{file_name}", locals: { data: data })
    case type
    when :file
      kit = PDFKit.new(html)
      kit.to_file(File.new("#{Rails.root}/tmp/#{Random.new_seed.to_s}", 'w+').path)
    when :pdf
      PDFKit.new(html, page_size: 'Letter').to_pdf
    end
  end

  def email_async(options = {})
    self.class.email_async(options)
  end

  # Moved method from ChangeLoggable module
  def create_change_log(attribute_name, value_before, value_after, description)
    ShivyogChangeLog.create(
      attribute_name: attribute_name,
      value_before: value_before,
      value_after: value_after,
      description: description,
      change_loggable_id: self.id,
      change_loggable_type: self.class.to_s
    )
  end

  def cal_completeness(required_field = nil)
    required_field =  (required_field.kind_of?(Array) ? required_field : nil) || (defined?(self.class::REQUIRED_FIELD) ? self.class::REQUIRED_FIELD : [])

    completness = 0.0000

    return 100.00 if required_field.compact.blank?

    per_field_weightage = 100.00/required_field.size

    required_field.each do |field|

      field_val = self.send("#{field}")
      if !field_val.nil? && !(field_val == "")
        completness +=  per_field_weightage
      end

    end

    completness.round
  end

  def is_complete?
    cal_completeness.to_i == 100
  end

  def search_syid(options = {})
    raise 'No search params found.' unless options.present?

    syid = "sy#{options[:syid][/-?\d+/].to_i}".upcase
    first_name = options[:first_name].to_s.strip.downcase
    mobile = options[:mobile].to_s.strip
    date_of_birth = Date.parse(options[:date_of_birth]) if options[:date_of_birth].present?

    sadhak_profile = SadhakProfile.where('syid = ? AND (LOWER(first_name) = ? OR mobile = ? OR date_of_birth = ?)', syid, first_name, mobile, date_of_birth).first

    if current_user.present? && options[:rc_event_id].present?
      sadhak_profile ||= SadhakProfile.find_by_syid(syid) if SadhakProfile.new.verify_by_rc(current_user, options[:rc_event_id])
    end
  ensure
    return sadhak_profile
  end

  # To words :: Float
  class ::Float
    def to_words
      in_words = []
      v = divmod 1
      in_words << v[0].to_i.to_words + ' rupees'
      if v[1].to_f.nonzero?
        decimal_in_words = ("%.2f" % v[1].to_f).split('.').last.to_i.to_words + " paisa"
        in_words = [in_words.last.to_s.gsub(' and ', ' ').split(' ').join(' ')] if in_words.size.nonzero?
        in_words << decimal_in_words
      end
      in_words.map(&:titleize).join(' and ') + ' Only'
    end
  end
  # To words :: BigDecimal
  class ::BigDecimal
    def to_words
      in_words = []
      v = divmod 1
      in_words << v[0].to_i.to_words + " rupees"
      if v[1].to_f.nonzero?
        decimal_in_words = ("%.2f" % v[1].to_f).split('.').last.to_i.to_words + " paisa"
        in_words = [in_words.last.to_s.gsub(' and ', ' ').split(' ').join(' ')] if in_words.size.nonzero?
        in_words << decimal_in_words
      end
      in_words.map(&:titleize).join(' and ') + ' Only'
    end
  end
end
