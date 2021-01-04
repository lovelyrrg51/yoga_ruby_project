class DigitalAsset < ApplicationRecord
  acts_as_paranoid

  # Constants
  # ALLOWED_AUTHORS = %w(Babaji Ishanji)

  # Virtual Attributes
  attr_accessor :asset_url
  attr_reader :signed_asset_url

  scope :author, ->(author) { where author: author }
  scope :tag, ->(tag) { joins(:asset_tags).where('asset_tag_mappings.asset_tag_id = ?', tag) }
  scope :event_type_id, lambda { |event_type_id| joins(:event_type_digital_asset_associations).where(event_type_digital_asset_associations: {event_type_id: event_type_id} ) }
  scope :event_types, lambda { |event_types| joins(:event_type_digital_asset_associations).where(event_type_digital_asset_associations: {event_type_id: event_types} ) }
  scope :published_on, lambda {|published_on| where('published_on <= ?', published_on) }
  scope :expires_at, lambda {|expires_at| where('expires_at >= ?', expires_at) }
  scope :language, lambda {|language| where('LOWER(language) IN (?)', (language.kind_of?(Array) ? language : [language]).map(&:downcase)) }
  scope :from_date, lambda {|from_date| where('published_on >= ?', from_date) }
  scope :to_date, lambda {|to_date| where('published_on <= ?', to_date) }
  scope :id, -> (id) { where.not(id: id) }
  scope :collection_id, -> (collection_id) { where(collection_id: collection_id) }
  scope :asset_name, -> (asset_name) { where("asset_name ILIKE ?", "%#{asset_name}%") }

  enum available_for: { all_platforms: 0, web: 1, chrome_app: 2, window: 3 }

  validates :asset_name, presence: true, length: { maximum: 255 }
  validates :expires_at, :published_on, :language, presence: true
  validate :has_valid_expires_at?, :has_valid_published_on?
  validate :create_or_update_digital_asset_secret, on: :create

  before_save :create_or_update_digital_asset_secret, if: Proc.new{|da| not da.digital_asset_secret_id.present? or da.asset_url != da.digital_asset_secret.asset_url }
  after_destroy :after_destroy_asset

  belongs_to :collection, optional: true
  has_many :purchased_digital_assets, dependent: :destroy
  has_many :users, through: :purchased_digital_assets
  has_one :asset_collection, class_name: 'Collection', foreign_key: 'source_asset_id'
  has_many :digital_assets, through: :asset_collection
  has_many :line_items, dependent: :destroy
  has_many :orders, through: :line_items
  has_many :asset_tag_mappings, dependent: :destroy
  has_many :asset_tags, through: :asset_tag_mappings

  belongs_to :digital_asset_secret
  has_many :asset_group_mappings
  has_many :user_groups, through: :asset_group_mappings, source: :user_group
  has_many :event_type_digital_asset_associations
  has_many :event_types, through: :event_type_digital_asset_associations
  has_many :cannonical_event_digital_asset_associations
  has_many :cannonical_events, through: :cannonical_event_digital_asset_associations
  # Default Scope
  # default_scope { where('published_on <= ? AND expires_at >= ?', Date.today.to_s, Date.today.to_s) }

  # searchable do
  #   text :asset_name, :boost => 2
  #   text :asset_description
  # end
  delegate :collection_name, to: :collection, allow_nil: true

  def valid_promo_code?(promo_code)
    code_array = JSON.parse(self.allowable_promo_code)
    code_array.include?(promo_code)
  end

  def self.preloaded_data
    DigitalAsset.order(:id).includes(includable_data)
  end

  def self.includable_data
    [:asset_tags, :user_groups, :digital_asset_secret, :event_types, :collection]
  end

  def s3_downloadable_url(bucket_name, expires_in = 7200)
    expires_in ||= 7200
    bucket_name ||= ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET']
    s3_downloadable_url = ''
    begin
      raise RuntimeError.new('No digital asset secret found.') if self.digital_asset_secret.nil?
      s3_downloadable_url = Aws::S3::Presigner.new.presigned_url(:get_object, bucket: bucket_name, key: self.digital_asset_secret.asset_url, expires_in: expires_in)

      # Update asset_dl_url in digital_asset_secret
      self.digital_asset_secret.update(asset_dl_url: s3_downloadable_url)
    rescue => e
      message = e.message
      logger.info(e.message)
      logger.info("Error while creating s3_downloadable_url.")
      logger.info(e.backtrace)
    end
    return s3_downloadable_url, message
  end

  def signed_asset_url
    s3_downloadable_url = ""
    return s3_downloadable_url if self.digital_asset_secret.nil?
    s3_file_path = self.digital_asset_secret.asset_url
    s3 = Aws::S3::Client.new(
      region: 'ap-south-1',
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
    s3 = Aws::S3::Resource.new(client: s3)
    bucket = s3.bucket(ENV['CLP_EPISODES_BUCKET'])
    uri = URI(s3_file_path)
    canonical_uri = URI.unescape(uri.path.gsub('+', ' '))
    s3_key = File.basename(canonical_uri, File.extname(canonical_uri))
    object = bucket.object(s3_key+"#{File.extname(canonical_uri)}")
    s3_downloadable_url = object.presigned_url(:get, :expires_in => 2.hours.to_i, :secure => true)
  end

  private

  def after_destroy_asset
    if !self.digital_asset_secret.nil?
      self.digital_asset_secret.destroy
    end
  end

  def has_valid_expires_at?
    errors.add(:expires_at, 'must be a valid date.') if ((Date.parse(expires_at.to_s) rescue ArgumentError) == ArgumentError)
    errors.empty?
  end

  def has_valid_published_on?
    errors.add(:published_on, 'must be a valid date.') if ((Date.parse(published_on.to_s) rescue ArgumentError) == ArgumentError)
    errors.empty?
  end

  def create_or_update_digital_asset_secret
    begin
      cdn_url = "http://d3mtufx3ge0c9w.cloudfront.net"

      s3 = Aws::S3::Client.new(region: 'ap-south-1')

      raise "Please input a valid asset url." unless asset_url =~ URI::regexp

      uri = URI(asset_url)

      canonical_uri = URI.unescape(uri.path.gsub('+', ' '))

      s3_key = canonical_uri.gsub("/#{ENV['CLP_EPISODES_BUCKET']}/", '')

      response = s3.head_object({
        bucket: ENV['CLP_EPISODES_BUCKET'],
        key: s3_key
      })

      puts "Headers: #{response.to_hash}"

      self.asset_file_size = response.content_length

      cdn_asset_url = canonical_uri.gsub("/#{ENV['CLP_EPISODES_BUCKET']}", '')

      asset_dl_url = asset_sd_url = asset_mobile_url = "#{cdn_url}#{URI.escape(cdn_asset_url)}"

      # Create/Update a digital asset secret

      digital_asset_secret_model = {asset_url: asset_url, asset_dl_url: asset_dl_url, asset_file_size: asset_file_size, asset_file_name: s3_key, asset_mobile_url: asset_mobile_url, asset_sd_url: asset_sd_url}

      digital_asset_secret = self.digital_asset_secret

      if digital_asset_secret.present?
        raise digital_asset_secret.errors.full_messages.first unless digital_asset_secret.update(digital_asset_secret_model)
      else
        digital_asset_secret = DigitalAssetSecret.new(digital_asset_secret_model)
        raise digital_asset_secret.errors.full_messages.first unless digital_asset_secret.save
      end

      self.digital_asset_secret_id = digital_asset_secret.id

    rescue URI::InvalidURIError => e
       errors.add(:base, "Please input a valid asset url.")
    rescue Exception => e
      errors.add(:base, e.message.presence || 'Could not find asset on aws-s3. Please upload it first.')
    end

    errors.empty?
  end

  def getSignatureKey(key, dateStamp, regionName, serviceName)
    kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
    kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
    kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
    kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")
    kSigning
  end
end
