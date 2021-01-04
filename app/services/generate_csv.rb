# frozen_string_literal: true
class GenerateCsv

  def self.generate options = {}
    options[:data_type] ||= 'string'

    csv_string = CSV.generate do |csv|
      csv << options.fetch(:header).map(&:upcase)
      options.fetch(:rows).each do |row|
        csv << row
      end
    end

    case options[:data_type]
    when 'string'
      csv_string
    when 'file'
      blob = Tempfile.new([Random.new_seed.to_s, '.csv'], "#{Rails.root}/tmp")
      blob.write(csv_string)
      blog
    else
      raise ArgumentError, 'Invalid data type'
    end
  end

end
