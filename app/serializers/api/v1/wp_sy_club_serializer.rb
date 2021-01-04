module Api::V1
  class WpSyClubSerializer < ActiveModel::Serializer
    attributes :id, :name, :members_count, :status, :email, :min_members_count, :content_type, :active_members_count, :has_board_members_paid
  end
end
