class Image < ApplicationRecord
  acts_as_paranoid

  # Papertrail logging
  has_paper_trail class_name: 'ImageVersion', only: [:name, :s3_url, :s3_path,
    :is_secure, :s3_bucket, :imageable_id, :imageable_type],
    skip: [], on: [:update, :destroy]

  diff :name, :s3_url, :s3_path, :is_secure, :s3_bucket, :imageable_id,
    :imageable_type, :created_at, :updated_at

  belongs_to :imageable, polymorphic: true
  belongs_to :advance_profile, class_name: 'AdvanceProfile', foreign_key: :imageable_id

  attr_accessor :image_data_base64, :s3_url

  mount_uploader :name, ImageUploader
  before_save :update_sadhak_profile_status, if: :advance_profile

  def get_s3_secure_url
    bucket = Aws::S3::Bucket.new(self.s3_bucket)
    object = bucket.object(self.s3_path)
    object.presigned_url(:get, expires_in: 10.seconds, virtual_host: true).to_s
  end

  def image_data_base64=(data)
    if data.present?
      in_content_type, encoding, string = data.split(/[:;,]/)[1..3]
      file = CarrierStringIO.new(Base64.decode64(string))
      self.name = file
    end
  end

  def s3_url
    name.url
  end

  def create_thumbanail
    name.recreate_versions! if self.name?
    Rails.logger.info "Image thumbnail has been generated"
  rescue => e
    Rails.logger.info "Image Url is not valid"
  end

  def thumb_url
    unless updated_at > ENV['THUMB_GEN_TIME']
      touch
      self.delay.create_thumbanail
      s3_url
    else
      name.thumb.url
    end
  end


  private
  def update_sadhak_profile_status
    case imageable_type
    when 'AdvanceProfilePhotograph'
      advance_profile.sadhak_profile.update_attribute(:profile_photo_status, 'pp_pending')
    when 'AdvanceProfileIdentityProof'
      advance_profile.sadhak_profile.update_attribute(:photo_id_status, 'pi_pending')
    when 'AdvanceProfileAddressProof'
      advance_profile.sadhak_profile.update_attribute(:address_proof_status, 'ap_pending')
    else
    end
  end

end

class CarrierStringIO < StringIO
  def original_filename
    "#{Random.new_seed.to_s}.png"
  end

  def content_type
    "image/jpeg"
  end
end
