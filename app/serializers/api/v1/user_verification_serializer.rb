module Api::V1
  class UserVerificationSerializer < ActiveModel::Serializer
    attributes :mobile, :email, :is_email_verified, :is_mobile_verified, :user_email, :user_id

    def user_email
      Utilities::MaskEmail.call(object&.user&.email)
    end

    def mobile
      Utilities::Mobile.new(object&.mobile).masked_number
    end

    def email
      Utilities::MaskEmail.call(object.email)
    end

  end
end
