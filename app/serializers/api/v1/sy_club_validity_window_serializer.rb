module Api::V1
  class SyClubValidityWindowSerializer < ActiveModel::Serializer
    attributes :id, :club_reg_start_date, :club_reg_end_date, :membership_start_date, :membership_end_date
  end
end
