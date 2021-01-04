module Api::V1
  class WpSadhakProfileSerializer < ActiveModel::Serializer
    attributes :id, :syid, :first_name, :middle_name, :last_name, :date_of_birth, :mobile, :email, :username, :active_club_ids
  
    #embed :ids
    has_many :joined_clubs
    has_many :sy_clubs
    has_one :address, include: true
  
  end
end
