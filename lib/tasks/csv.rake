namespace :csv do
require 'csv'
desc "TODO"
    task name: :environment do
#       csv = CSV.read('States.csv', :encoding => 'ISO-8859-1')
#       puts csv[0]
#       CSV.foreach('sadhak_profiles_final.csv', :encoding => 'ISO-8859-1') do |row|
#          p = SadhakProfile.new(:id => row[0], :syid => row[1], first_nae: row[2] )
#          puts "#{row}"
#          if p.save
#            puts "succcess"
#          else
#            puts p.errors
#         end
        
      File.open("sadhak_profile_test.txt", "r").each do |line|
        id, syid, fname, lname, gender, dob, addline1, addline2, village, password, tel, mobile, profession, date, last_update, country, city, state =  line.strip.split("\t")
          if city != 'Others'  and state != 'Others' and country != 'Others'
            @city = DbCity.where(name: city).last
            @state = DbState.where(name: state).last
            @country = DbCountry.where(name: country).last
            # use this commented code in update_aaddress task. next time will add to same task      
#             @country = DbCountry.find_by(name: country)
#             @state = @country.states.where(name: state).last
#             @city = @state.cities.where(name: city).last
          else
            if city == 'Others'
              @city = nil
              @state = DbState.where(name: state).last
              @country = DbCountry.where(name: country).last
            end
            if state == 'Others'
              @state = nil
              @city = DbCity.where(name: city).last
              @country = DbCountry.where(name: country).last
            end
            if country == 'Others'
              @country = nil
              @city = DbCity.where(name: city).last
              @state = DbState.where(name: state).last
            end
          end
        sadhak_profile = SadhakProfile.new(id: id[/-?\d+/].to_i, syid: syid, first_name: fname, last_name: lname, gender: gender, date_of_birth: dob, phone: tel, mobile: mobile, created_at: date, updated_at: last_update)
#         sadhak_profile = SadhakProfile.find_by(id: id[/-?\d+/].to_i)
        if sadhak_profile.present?
          ActiveRecord::Base.transaction do
            if sadhak_profile.save!
              if @city.present? or @state.present? or @country.present?
                if sadhak_profile.address.present?
                  if @city.present?
                    city_id = @city.id
                  else
                    city_id = nil
                  end
                  if @state.present?
                    state_id = @state.id
                  else
                    state_id = nil
                  end
                  if @country.present?
                    country_id = @country.id
                  else
                    country_id = nil
                  end
                  puts city_id, city
                  puts state_id, state
                  puts country_id, country
                  puts syid
#                   end
                  sadhak_profile_address = sadhak_profile.address.update_attributes(first_line: addline1, second_line: addline2, city_id: city_id, state_id: state_id, country_id: country_id, addressable_type: "SadhakProfile")
                else
                sadhak_profile_address = sadhak_profile.create_address(first_line: addline1, second_line: addline2, city_id: @city.try(id), state_id: @state.try(id), country_id: @country.try(id), addressable_type: "SadhakProfile")
                end
                puts sadhak_profile_address
              else 
                puts "Data missing"
              end
              sp_profession = Profession.find_or_create_by(name: profession)
              sadhak_profile.create_professional_detail(profession_id: sp_profession.id)
              puts sadhak_profile
            else
              puts sadhak_profile.attributes
              puts sadhak_profile.id
              puts "error on saving"
            end
          end
        end
      end
    end
  task update_email: :environment do
    File.open("sadhak_profile_email.txt", "r").each do |line|
      id, email=  line.strip.split("\t")
        sadhak_profile =  SadhakProfile.find_by(id: id[/-?\d+/].to_i)
      if sadhak_profile.email.nil?
        sadhak_profile.update_attributes(email: email)
#         sadhak_profile.save
        puts email
      else
        puts "email is present"
      end
    end
  end
  task add_event_type: :environment do
    File.open("master_event_type.csv", "r").each do |line|
      id, event_type =  line.strip.split(",")
      puts id, event_type
      event_type =  EventType.new(id: id[/-?\d+/].to_i, name: event_type)
      if event_type.save
        puts event_type
      else
        puts "error on saving"
      end
    end
  end
  #rake csv:add_country_code
  task add_country_code: :environment do
    File.open("country_code.csv", "r").each do |line|
      id, isdcode =  line.strip.split(",")
      if isdcode.present?
        country =  DbCountry.find_by(id: id[/-?\d+/].to_i)
        puts country.telephone_prefix
        if country.telephone_prefix.nil?
          country.update_attributes(telephone_prefix: isdcode)
          puts isdcode
        else
          puts "isdcode is present"
        end
      end
    end
  end
  task add_spiritual_practice: :environment do
    File.open("sadhak_profile_sp_practice.csv", "r").each do |line|
      userid, userspiritualpracticeid, morningduration, afternoonduration, eveningduration, otherduration, spiritualfrequency =  line.strip.split(",")
      @morningduration = morningduration[/-?\d+/].to_i.ceil
      @afternoonduration = afternoonduration[/-?\d+/].to_i.ceil
      @eveningduration = eveningduration[/-?\d+/].to_i.ceil
      if spiritualfrequency == 'Only during shivirs' or spiritualfrequency == 'NULL'
        spiritualfrequency = 'only_during_shivir'
      end
#       puts @morningduration, @afternoonduration, @eveningduration
      sadhak_profile = SadhakProfile.find_by(id: userid[/-?\d+/].to_i )
      if sadhak_profile.present?
       sp =  SpiritualPractice.find_by(id: userspiritualpracticeid[/-?\d+/].to_i)
        if sp.present?
          sp.update_attributes(id: userspiritualpracticeid[/-?\d+/].to_i, morning_sadha_duration_hours: @morningduration, afternoon_sadha_duration_hours: @afternoonduration,
evening_sadha_duration_hours: @eveningduration, other_sadha_duration_hours: @otherduration, sadhana_frequency_days_per_week: spiritualfrequency.downcase, sadhak_profile_id: sadhak_profile.id)
          puts "Already present"
        else
          if spiritualfrequency == 'daily' or spiritualfrequency == 'weekly' or spiritualfrequency == 'only_during_shivir'
            spiritual_practice = SpiritualPractice.new(id: userspiritualpracticeid[/-?\d+/].to_i, morning_sadha_duration_hours: @morningduration, afternoon_sadha_duration_hours: @afternoonduration,
evening_sadha_duration_hours: @eveningduration, other_sadha_duration_hours: @otherduration, sadhana_frequency_days_per_week: spiritualfrequency.downcase, sadhak_profile_id: sadhak_profile.id)
            if spiritual_practice.save
              puts spiritual_practice
            else
              puts  "error on saing"
            end
          else
            puts 'sadhna frquency not valid'
          end
        end
      else
        puts "sadhak profile not found"
      end
    end  
  end
  task add_spiritual_journey: :environment do
    File.open("sadhak_profile_spiritual_journey.txt", "r").each_with_index do |line, index|
      userspiritualjourneyid, userid, joiningreason, eventattendedplace, eventattendedmonth, eventattendedyear, sourceinfo  =  line.strip.split("\t")
      puts sourceinfo, eventattendedplace , userspiritualjourneyid, userid
            sadhak_profile = SadhakProfile.where(id: userid[/-?\d+/].to_i).last
      if sadhak_profile.present?
        sj =  SpiritualJourney.find_by(id: userspiritualjourneyid[/-?\d+/].to_i)
        if sj.present?
          sj.update_attributes(id: userspiritualjourneyid[/-?\d+/].to_i, source_of_information: try(sourceinfo), reason_for_joining: try(joiningreason), first_event_attended: try(eventattendedplace), first_event_attended_year: try(eventattendedyear),  first_event_attended_month: try(eventattendedmonth), sadhak_profile_id: userid[/-?\d+/].to_i)
          puts "updated"
          puts sj.id
        else
          spiritual_journey = SpiritualJourney.new(id: userspiritualjourneyid[/-?\d+/].to_i, source_of_information: try(sourceinfo), reason_for_joining: try(joiningreason), first_event_attended: try(eventattendedplace), first_event_attended_year: try(eventattendedyear),  first_event_attended_month: try(eventattendedmonth), sadhak_profile_id: userid[/-?\d+/].to_i)
          if spiritual_journey.save!
            puts "success"
            puts userspiritualjourneyid
          else
            puts "error on saving"
          end
        end
      else
        puts "sadhak profile not found"
      end
    end
  end
  task add_other_association: :environment do
    File.open("user_org_association.csv", "r").each do |line|
      userorgassociationid, userid, isapproved, lastupdatdate, orgname, associatedas, associatedyear, associatedmonth, practiceduration =  line.strip.split(",")
      sadhak_profile = SadhakProfile.where(id: userid[/-?\d+/].to_i).last
      if sadhak_profile.present?
        ospa =  OtherSpiritualAssociation.find_by(id: userorgassociationid[/-?\d+/].to_i)
        if ospa.present?
          ospa.update_attributes(id: userorgassociationid[/-?\d+/].to_i, organization_name: try(orgname), association_description: try(associatedas), associated_since_year: try(associatedyear), duration_of_practice: try(practiceduration), associated_since_month: try(associatedmonth), sadhak_profile_id: userid[/-?\d+/].to_i)
          puts "updated"
          puts ospa.id
        else
          other_association = OtherSpiritualAssociation.new(id: userorgassociationid[/-?\d+/].to_i, organization_name: try(orgname), association_description: try(associatedas), associated_since_year: try(associatedyear), duration_of_practice: try(practiceduration),  associated_since_month: try(associatedmonth), sadhak_profile_id: userid[/-?\d+/].to_i)
          if other_association.save
            puts "success"
            puts userorgassociationid
          else
            puts "error on saving"
          end
        end
      else
        puts "sadhak profile not found"
      end
    end  
  end
  task add_event_registration: :environment do
    File.open("event_app_4751.csv", "r").each do |line|
      usereventappid, eventid, userid =  line.strip.split(",")
      puts usereventappid, eventid, userid
      event_registration = EventRegistration.new(event_id: eventid[/-?\d+/].to_i, sadhak_profile_id: userid[/-?\d+/].to_i)
      if event_registration.save!
        puts event_registration.attributes
      else
        puts "can't be save"
      end
    end
  end
  
  task update_is_mobile_and_email_verified: :environment do
    File.open("sadhak_profile_email.txt", "r").each do |line|
      id, email=  line.strip.split("\t")
        sadhak_profile =  SadhakProfile.find_by(id: id[/-?\d+/].to_i)
      if sadhak_profile.address.present?
        country = sadhak_profile.address.country_id
        if country.present?
          telephone_prefix = DbCountry.find(country).telephone_prefix
        else
          puts "country not found"
          telephone_prefix == '91'
        end
  #       puts country_code
        if telephone_prefix == "91" and telephone_prefix.present?
          sadhak_profile.update_attributes(is_mobile_verified: true, is_email_verified: false)
          puts "mobile verified"
          puts telephone_prefix
           puts sadhak_profile.id
        else
            sadhak_profile.update_attributes(is_email_verified: true, is_mobile_verified: false)
          puts "email verified" 
          puts sadhak_profile.id
        end
      else
        sadhak_profile.update_attributes(is_email_verified: true)
        puts "email verified"
        puts "address not found"
        puts sadhak_profile.id
      end
    end
  end
  
  # run only once just because of previous changes of data import on sadhak_profile_address
  task update_address: :environment do
    File.open("address_with_syid.csv", "r").each do |line|
      userid, syid, cityid, countryid, stateid =  line.strip.split(",")
      puts userid, syid, cityid, countryid, stateid
      sadhak_profile =  SadhakProfile.find_by(syid: syid)#userid[/-?\d+/].to_i)
      
      if sadhak_profile.present?
        @country = DbCountry.find(countryid)
        @state = @country.states.where(id: stateid).last if @country.present?
        @city = @state.cities.where(id: cityid).last if @state.present?
        if @country.present? and @state.present? and @city.present?
# if condition is just to update a particular record which causing problem while testing
          if syid == "SY10866"
            puts sadhak_profile.attributes
            puts countryid, stateid, cityid
            sadhak_profile.address.update_attributes(city_id: @city.id, state_id: @state.id, country_id: @country.id)
          else
#         address = sadhak_profile.address.update_attributes(city_id: city, state_id: state, country_id: country)
            puts @country.name, @state.name, @city.name
          end
        end
      end
    end
  end
  
  
  desc "Common task for import data"
  task :main => [ :name, :update_email, :add_event_type, :add_country_code, :add_spiritual_practice, :add_spiritual_journey, :add_other_association, :add_event_registration, :update_is_mobile_and_email_verified ]
  
#   task add_aspect_of_life: :environment do
#     File.open("user_org_association.csv", "r").each do |line|
#       userorgassociationid, userid, isapproved, lastupdatdate, orgname, associatedas, associatedyear, associatedmonth, practiceduration =  line.strip.split(",")
#       sadhak_profile = SadhakProfile.where(id: userid[/-?\d+/].to_i).last
#       if sadhak_profile.present?
#         ospa =  OtherSpiritualAssociation.find_by(id: userorgassociationid[/-?\d+/].to_i)
#         if ospa.present?
#           ospa.update_attributes(id: userorgassociationid[/-?\d+/].to_i, organization_name: try(orgname), association_description: try(associatedas), associated_since_year: try(associatedyear), duration_of_practice: try(practiceduration), associated_since_month: try(associatedmonth), sadhak_profile_id: userid[/-?\d+/].to_i)
#           puts "updated"
#           puts ospa.id
#         else
#           other_association = OtherSpiritualAssociation.new(id: userorgassociationid[/-?\d+/].to_i, organization_name: try(orgname), association_description: try(associatedas), associated_since_year: try(associatedyear), duration_of_practice: try(practiceduration),  associated_since_month: try(associatedmonth), sadhak_profile_id: userid[/-?\d+/].to_i)
#           if other_association.save
#             puts "success"
#             puts userorgassociationid
#           else
#             puts "error on saving"
#           end
#         end
#       else
#         puts "sadhak profile not found"
#       end
#     end  
#   end
  
end