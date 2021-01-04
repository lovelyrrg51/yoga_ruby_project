namespace :release_data_csv do
  require 'csv'

  desc "SadhakProfileFreshData"
  task add_doctors_profile_data: :environment do
    File.open("medical_contact_data.csv", "r").each do |medical_data|
      id,syid, surname, first_name, male, female, dob, address, city, state, pin_code, country, email, profession, home_telephone, mobile =  medical_data.strip.split(",")
      puts id,syid, surname, first_name, male, female, dob, address, city, state, pin_code, country, email, profession, home_telephone, mobile
      # to find whether country, state, coty is present
      if city != 'Others'  and state != 'Others' and country != 'Others'
        city_name = city.titleize
        state_name = state.titleize
        country_name = country.titleize
        @country = DbCountry.where(name: country_name).last
        @state =  @country.states.where(name: state_name).last if @country.present?
        @city =  @state.cities.where(name: city_name).last if @state.present?


      else
        if city == 'Others'
          @city = nil
          @state = DbState.where(name: state_name).last
          @country = DbCountry.where(name: country_name).last
        end
        if state == 'Others'
          @state = nil
          @city = DbCity.where(name: city_name).last
          @country = DbCountry.where(name: country_name).last
        end
        if country == 'Others'
          @country = nil
          @city = DbCity.where(name: city_name).last
          @state = DbState.where(name: state_name).last
        end
      end
      # to check pin_code
      if pin_code.present?
        @pin_code = pin_code
      else
        @pin_code = nil
      end

      # to assign the gender
      if male == 'TRUE'
        gender = 'male'
      elsif female == "TRUE"
        gender = 'female'
      else
        gender = nil
      end
      if home_telephone.present?
        @telephone = home_telephone
      else
        @telephone = nil
      end
      if mobile.present?  and mobile.length > 10
        @mobile = mobile.byteslice((mobile.length-10)..mobile.length).delete(' ')
      else
        @mobile = nil
      end
      sadhak_profile = SadhakProfile.new(first_name: first_name, last_name: surname, gender: gender, date_of_birth: dob.to_date, phone: @telephone, mobile: @mobile, email: email, username: first_name.delete(' ').to_s+ "doc")
      if sadhak_profile.present?
        #         ActiveRecord::Base.transaction do
        if sadhak_profile.save!
          sadhak_profile.update_attributes(is_email_verified: true)
          if sadhak_profile.address.present?
            if @country.present? and @state.present? and @city.present?
              # if condition is just to update a particular record which causing problem while testing
              puts city_id, city
              puts state_id, state
              puts country_id, country
              puts syid
              sadhak_profile_address = sadhak_profile.address.update_attributes(first_line: @address, second_line:  nil, city_id: city_id, state_id: state_id, country_id: country_id, addressable_type: "SadhakProfile")
            else
              sadhak_profile_address = sadhak_profile.create_address(first_line: @address, second_line: nil, city_id: @city.try(id), state_id: @state.try(id), country_id: @country.try(id), addressable_type: "SadhakProfile", postal_code: @pincode)
            end
            puts sadhak_profile_address
            sp_profession = Profession.find_or_create_by(name: profession.titleize)
            sadhak_profile.create_professional_detail(profession_id: sp_profession.id)
            puts sadhak_profile.attributes
            puts sadhak_profile.user
          end
        end
      end
    end
  end
end
