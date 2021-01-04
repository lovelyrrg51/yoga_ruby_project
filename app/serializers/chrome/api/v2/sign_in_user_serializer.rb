class Chrome::Api::V2::SignInUserSerializer < ActiveModel::Serializer

  attributes :id, :username, :authentication_token, :sy_club, :club_admin, :board_member_position, :board_member_forum_name, :is_board_member, :is_valid_board_member, :unpaid_board_members, :forum_min_member_count, :has_min_forum_members, :collections, :is_shivir_episodes_accessible, :is_farmer_episodes_accessible, :digital_store_admin, :super_admin

    has_many :sadhak_profile, serializer: Chrome::Api::V2::SignInSadhakProfileSerializer, include: true
    has_one :address, serializer: Chrome::Api::V2::SignInAddressSerializer, include: true


    def sy_club
      object.try(:active_club).present? ? Chrome::Api::V2::SignInSyClubSerializer.new(object.try(:active_club)) : {}
    end

    def board_member_position
      object.try(:sadhak_profile).try(:board_member_position) || (object.try(:sadhak_profile).try(:advisory_counsil).present? ? "Advisory Council" : "")
    end

    def board_member_forum_name
      object.try(:sadhak_profile).try(:board_member_forum_name) || object.try(:sadhak_profile).try(:advisory_counsil).try(:sy_club).try(:name)
    end

    def is_board_member
      object.try(:sadhak_profile).try(:sy_clubs).try(:first).present? || object.try(:sadhak_profile).try(:advisory_counsil).try(:sy_club).present?
    end

    def is_valid_board_member
      sadhak_profile = object.try(:sadhak_profile)
      sy_club = sadhak_profile.try(:sy_clubs).try(:first) || sadhak_profile.try(:advisory_counsil).try(:sy_club)

      sy_club.present? && (sadhak_profile.try(:active_club_ids) || []).size > 0 && sy_club.has_board_members_paid && sy_club.active_members_count >= sy_club.min_members_count
    end

    def unpaid_board_members
      object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:unpaid_board_members) || []
    end

    def forum_min_member_count
      object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:min_members_count)
    end

    def has_min_forum_members
      forum_active_member_count = object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:active_members_count)
      forum_min_member_count = object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:min_members_count)
      forum_active_member_count && forum_min_member_count && forum_active_member_count >= forum_min_member_count
    end

    def collections
      collections = object.try(:collections_for_chrome_extension)
      collections.present? ? ActiveModelSerializers::SerializableResource.new(collections, adapter: :attributes, each_serializer: Chrome::Api::V2::CollectionSerializer) : []
    end

    def is_shivir_episodes_accessible
      object.try(:sadhak_profile).try(:accessible_shivir_type_episodes).present?
    end

    def is_farmer_episodes_accessible
      object.try(:sadhak_profile).try(:can_view_shivir_collection)
    end

  end
  