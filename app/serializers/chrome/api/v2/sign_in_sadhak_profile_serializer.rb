class Chrome::Api::V2::SignInSadhakProfileSerializer < ActiveModel::Serializer

    attributes :id, :syid, :first_name, :last_name, :gender, :date_of_birth, :mobile, :email

end
