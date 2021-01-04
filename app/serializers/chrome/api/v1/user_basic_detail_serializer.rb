class Chrome::Api::V1::UserBasicDetailSerializer < ActiveModel::Serializer
  attributes :id, :syid, :forum_name, :board_member_position, :full_name, :email

  def syid
    object.try(:sadhak_profile).try(:syid)
  end

  def forum_name
    object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:name)
  end

  def board_member_position
    object.try(:sadhak_profile).try(:board_member_position)
  end

  def full_name
    object.try(:sadhak_profile).try(:full_name)
  end

  def email
    object.try(:sadhak_profile).try(:email)
  end

end
