module Api::V1
  class WpSadhakProfileSearchSerializer < ActiveModel::Serializer
    attributes :id, :syid, :first_name, :last_name, :full_name, :forum_name
  
    def forum_name
      object.active_club.try(:name)
    end
  
  end
end
