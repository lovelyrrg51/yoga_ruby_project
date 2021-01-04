class GenerateSadhakProfilesExcel

  def self.call(profiles, type, opts = [])
    header = %w(
      SNO
      SYID
      FIRST_NAME
      LAST_NAME
      GENDER
      MOBILE
      EMAIL
      DATE_OF_BIRTH
      PHOTO_ID_UPLOADED
      PHOTO_ID_APPROVED
      PHOTO_ID_PROOF_UPLOADED
      PHOTO_ID_PROOF_APPROVED
      PHOTO_ID_PROOF_NUMBER
      ADDRESS_PROOF_UPLOADED
      ADDRESS_PROOF_APPROVED
      PHOTO_ID_LAST_UPDATED
      PHOTO_ID_PROOF_LAST_UPDATED
      STATUS
      COUNTRY
      STATE
      CITY
      STREET_ADDRESS
      EDUCATIONAL_QUALIFICATION
      PROFESSION OCCUPATION
      SOURCE_OF_INFORMATION
      SOURCE_OF_INFORMATION(MEDIA)
      ALTERNATIVE_SOURCE
      CREATION_DATE
      FORUM_INFO
      PROFILE_STATUS_LOG
    )

    if type.try(:downcase) == 'banned'
      header.push('REASON_FOR_BANNED')
    end

    opts.each do |opt|
      header.push(opt[:header_name]) if opt[:header_name].present? and opt[:proc].kind_of?(Proc)
    end

    rows = []

    profiles = profiles.includes({ shivyog_change_logs: [ creator: :sadhak_profile ] }, { spiritual_journey: [ :source_info_type ] }, { professional_detail: [ :profession ] }, { advance_profile: [ :advance_profile_photograph, :advance_profile_identity_proof, :advance_profile_address_proof ] }, { address: [:db_city, :db_state, :db_country] }, { forum_memberships: [:sy_club] }, { sy_club_sadhak_profile_associations: [:sy_club_user_role] }, :sy_clubs)

    # Iterate over event registrations with status [nil, updated]
    profiles.find_each(batch_size: 100).with_index do |sadhak_profile, index|
      sadhak_address = sadhak_profile.address
      row = []
      row << (index + 1)
      row << sadhak_profile.try(:syid)
      row << sadhak_profile.try(:first_name)
      row << sadhak_profile.try(:last_name)
      row << sadhak_profile.try(:gender)
      row << sadhak_profile.try(:mobile)
      row << sadhak_profile.try(:email)
      row << sadhak_profile.try(:date_of_birth).try(:strftime, '%b %d, %Y')
      row << (sadhak_profile.try(:advance_profile).try(:advance_profile_photograph).present? ? 'Yes' : 'No')
      row << (sadhak_profile.try(:profile_photo_status) == 'pp_success' ? 'Yes' : 'No')
      row << (sadhak_profile.try(:advance_profile).try(:advance_profile_identity_proof).present? ? 'Yes' : 'No')
      row << (sadhak_profile.try(:photo_id_status) == 'pi_success' ? 'Yes' : 'No')
      row << sadhak_profile.try(:advance_profile).try(:photo_id_proof_number).to_s
      row << (sadhak_profile.try(:advance_profile).try(:advance_profile_address_proof).present? ? 'Yes' : 'No')
      row << (sadhak_profile.try(:address_proof_status) == 'ap_success' ? 'Yes' : 'No')
      row << sadhak_profile.try(:advance_profile).try(:advance_profile_photograph).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
      row << sadhak_profile.try(:advance_profile).try(:advance_profile_identity_proof).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
      row << sadhak_profile.try(:status).try(:titleize)
      row << sadhak_address.try(:country_name)
      row << sadhak_address.try(:state_name)
      row << sadhak_address.try(:city_name)
      row << sadhak_address.try(:street_address)
      row << sadhak_profile.try(:professional_detail).try(:highest_degree)
      row << sadhak_profile.try(:professional_detail).try(:profession).try(:name)
      row << sadhak_profile.try(:professional_detail).try(:occupation)
      row << sadhak_profile.try(:spiritual_journey).try(:source_info_type).try(:source_name)
      row << sadhak_profile.try(:spiritual_journey).try(:sub_source_type).try(:sub_source_name)
      row << sadhak_profile.try(:spiritual_journey).try(:alternative_source)
      row << sadhak_profile.try(:created_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
      row << sadhak_profile.try(:active_forum_name)

      row << sadhak_profile.shivyog_change_logs.where(attribute_name: 'status').last(3).collect do |log|
          sp = log.try(:creator).try(:sadhak_profile) 
          "Status changed from #{log.value_before || 'NA'} to #{log.value_after} with comments #{log.description} at #{log.created_at.try(:strftime, '%b %d, %Y - %I:%M:%S %p')} by #{sp.try(:syid)}-#{sp.try(:full_name)}"
        end.join(' | ')

      opts.each do |opt|
        row.push(opt[:proc].call(sadhak_profile)) if opt[:header_name].present? and opt[:proc].kind_of?(Proc)
      end

      rows.push(row)
    end

    { header: header, rows: rows }
  end

end
