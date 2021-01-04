module SadhakProfilesHelper

  def medical_practitioners_profile_work_enviroment_list

    [['Academia','academia'], ['Administrator','administrator'], ['Goverment Regular','goverment_regular'], ['Medical Director','medical_director'], ['Private Practice','private_practice'], ['Research', 'research'], ['Retired Physican', 'retired_physican'], ['Employed Physican', 'employed_physican']]
    
  end

  def medical_practitioners_profile_current_professional_role_list

    [['Physician', 'physician'], ['Therapist', 'therapist'], ['Health Care Extender', 'health_care_extender'], ['Medical Student', 'medical_student'], ['OTHER', 'other']]

  end

  def sadhak_seva_preference_availability_list

    [['from 2 hrs before the shivir', 'before_2_hours'], ['during shivir breaks', 'during_breaks'], ['for up to 1 hr after the shivir', 'after_1_hour']]

  end

  def sadhak_seva_preference_seva_preference_list

    [['Hall', 'hall'], ['Catering', 'catering'], ['Car Park', 'car_park'], ['Divine Shop', 'divine_shop'], ['Shoe', 'shoe'], ['Facilities', 'facilities'], ['Registeration', 'registeration'], ['Stage', 'stage'], ['Music', 'music'], ['Queue Management', 'queue_management'], ['Other', 'other']]

  end

  def page_entries_info(collection)
    if collection.present?
      if params[:page].blank?
        %{Displaying 1 of %d page(s)} % [
          collection.total_pages
        ]
      else
        %{Displaying %d of %d page(s)} % [
          params[:page],
          collection.total_pages
        ]
      end
    end
  end

end
