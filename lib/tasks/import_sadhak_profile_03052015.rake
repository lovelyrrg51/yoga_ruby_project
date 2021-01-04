namespace :import_sadhak_profile_03052015 do
  require 'csv'

  # rake import_sadhak_profile_03052015:import_sadhak_profiles["sadhak.shivyog.com/Sadhak Profiles/sadhaks_54220_55679_plus_missing.csv"]
  desc "SadhakProfileFreshData"
  task :import_sadhak_profiles, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      sadhak_errors = []
      errors = []
      ActiveRecord::Base.transaction do
        File.open(@file, "r").each do |line|
          # id, syid, fname, mname, lname, email, username, gender, mobile, dob =  line.strip.split(",") # for previous migration before 27_09_2015
          # puts  id, syid, fname, mname, lname, email, username, gender, mobile, dob
          id, syid, fname, mname, lname, email, gender, mobile, dob, username, marital_status =  line.strip.split(",")
          # puts  id, syid, fname, mname, lname, email, gender, mobile, dob, username, marital_status
          # marital_status_arr = ['a', 'Single', 'Married', 'Divorced', 'Widow']
          username = username.strip

          # Push error message and move next if sadhak profile already exist
          if SadhakProfile.find_by_id(id[/-?\d+/].to_i).present?
            errors.push("Sadhak profile already exist with id: #{id}")
            next
          end

          if id[/-?\d+/].to_i > 101
            if username == "NULL" or username == "'" or username == ''
              user_name = fname.strip.to_s + "_" + id.to_s
            else
              user_name = username
            end
            if SadhakProfile.where(username: user_name).count > 0 and username.present?
              user_name = username + "_" + id.to_s
            end
            @mobile = mobile.present? ? mobile : nil
            @email = email.present? ? email : 'XXnoemail@gmaill.com'
            sadhak_profile = SadhakProfile.find_or_create_by(id: id[/-?\d+/].to_i, syid: syid, first_name: fname, middle_name: mname, last_name: lname, gender: gender.try(:downcase), mobile: @mobile, date_of_birth: dob.to_s, email: @email, username: user_name, marital_status: marital_status.try(:downcase))
            if sadhak_profile and sadhak_profile.errors.empty?
              puts "sadhak profile saved - #{sadhak_profile.id}"
            else
              sadhak_errors.push("#{id}-#{sadhak_profile.try(:errors).try(:full_messages)}")
            end
            if sadhak_errors.present?
              raise ActiveRecord::Rollback, "Some error occured."
            end
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    puts "errors with id"
    binding.pry if Rails.env == "development"
    puts sadhak_errors
    puts errors
  end

  ### to update address, filename: address_31072015.csv
  # rake import_sadhak_profile_03052015:import_address["sadhak.shivyog.com/Sadhak Profiles/sadhaks_address_54220_55679_plus_missing.csv"]
  task :import_address, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      errors = []
      ActiveRecord::Base.transaction do
        File.open(@file, "r").each_with_index do |line, index|
          next unless line.strip.present?
          id, syid, countryid, stateid, cityid, pincode, address1, address2 =  line.strip.split("\t")
          # print "#{id}, #{syid}, #{countryid}, #{stateid}, #{cityid}, #{pincode}, #{address1}, #{address2}\n"
          # next
          if id[/-?\d+/].to_i
            sadhak_profile =  SadhakProfile.find_by(syid: syid)#userid[/-?\d+/].to_i)
            if sadhak_profile.present?
              if countryid[/-?\d+/].to_i > 0
                @country = DbCountry.find(countryid)
                if  stateid[/-?\d+/].to_i > 0 and cityid[/-?\d+/].to_i > 0
                  @state = @country.states.where(id: stateid).first if @country.present?
                  @city = @state.cities.where(id: cityid).first if @state.present?
                elsif stateid[/-?\d+/].to_i > 0 and (cityid[/-?\d+/].to_i < 0 or cityid[/-?\d+/] == nil)
                  @state = @country.states.where(id: stateid).first
                  @city = 'Others'
                elsif stateid[/-?\d+/].to_i < 0 or stateid[/-?\d+/] == nil
                  @state = 'Others'
                elsif (stateid[/-?\d+/].to_i < 0 or stateid[/-?\d+/] == nil) and (cityid[/-?\d+/].to_i < 0 or cityid[/-?\d+/] == nil)
                  @city = 'Others'
                  @state = 'Others'
                else
                  puts 'nothing'
                end
                if @country.present? and @state.present? and @city.present?
                  if @state == 'Others' and @city == 'Others'
                    @country_id = @country.id
                    @state_id = 99999
                    @city_id = 999999
                  elsif @state == 'Others'
                    @country_id = @country.id
                    @state_id = 99999
                    @city_id = 999999
                  elsif @city == 'Others'
                    @country_id = @country.id
                    @state_id = @state.id
                    @city_id = 999999
                  else
                    @country_id = @country.id
                    @state_id = @state.id
                    @city_id = @city.id
                  end
                  # puts id, @country_id, @state_id, @city_id
                  duplicate = SadhakProfile.joins(:address).where("first_name = ? and date_of_birth = ? and addresses.city_id = ?", sadhak_profile.first_name, sadhak_profile.date_of_birth, @city_id).first
                  if duplicate.present?
                    errors.push("Error in updating duplicate profile: #{syid}") unless sadhak_profile.update(first_name: "#{sadhak_profile.first_name}_#{sadhak_profile.id}")
                  end
                  if sadhak_profile.address.present?
                    unless sadhak_profile.address.update_attributes(city_id: @city_id, state_id: @state_id, country_id: @country_id, first_line: address1, second_line: address2, postal_code: pincode)
                      errors.push("Error in updating address: #{syid}")
                    end
                  else
                    sadhak_profile_address = sadhak_profile.build_address(city_id: @city_id, state_id: @state_id, country_id: @country_id, addressable_id: sadhak_profile.id, addressable_type: 'SadhakProfile', first_line: address1, second_line: address2, postal_code: pincode)
                    if sadhak_profile_address.save
                      puts "Address saved #{syid} - Index: #{index + 1}."
                    else
                      errors.push("Error in saving #{syid} with errors: #{sadhak_profile_address.errors.full_messages}")
                    end
                  end
                  if errors.present?
                    raise ActiveRecord::Rollback, "Some error occured."
                  end
                end
              end
            end
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    puts "error"
    binding.pry if Rails.env == "development"
    puts errors
  end

  ## To update is mobile verified or email verified, , #filename: users_id_syid_31072015.csv
  # rake import_sadhak_profile_03052015:update_is_mobile_and_email_verified["sadhak.shivyog.com/Sadhak Profiles/sadhaks_address_54220_55679_plus_missing.csv"]
  task :update_is_mobile_and_email_verified, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      errors = []
      ActiveRecord::Base.transaction do
        # File.open("syid_with_fname_03052015.csv", "r").each do |line| #commented on 31072015
        File.open(@file, "r").each_with_index do |line, index|
          next unless line.strip.present?
          id, syid =  line.strip.split(",")
          sadhak_profile =  SadhakProfile.find_by(syid: syid)
          if sadhak_profile.present?
            if sadhak_profile.address.present?
              country = sadhak_profile.address.try(:db_country)
              if country.present?
                telephone_prefix = country.telephone_prefix
              else
                telephone_prefix == '91'
              end
              if telephone_prefix.present? and telephone_prefix == "91" and sadhak_profile.mobile.present?
                is_mobile_verified = true
                is_email_verified = false
              elsif sadhak_profile.email.present?
                is_mobile_verified = false
                is_email_verified = true
              else
                is_mobile_verified = false
                is_email_verified = false
              end
              raise Exception, "Exception occured while updating sadhak profile: #{sadhak_profile.id}." unless sadhak_profile.update_attributes(is_email_verified: is_email_verified, is_mobile_verified: is_mobile_verified)
            elsif sadhak_profile.email.present?
              sadhak_profile.update_attributes(is_email_verified: true)
            else
              errors.push({sadhak_profile_id: sadhak_profile.id, message: "Sadhak neither have email and mobile."})
            end
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_professional_details["sadhak.shivyog.com/Professional Detail/professional_detail.csv"]
  desc "Import sadhak professional details."
  task :import_professional_details, [:filename, :start, :batch_size] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(professional_detail: [:profession]).all
      professions = Profession.all

      start = args[:start].present? ? args[:start].to_i : 0
      batch_size = args[:batch_size].present? ? args[:batch_size].to_i : 10000

      csv = CSV.read(@file)
      header = csv[0] - [nil]

      data = csv[(start + 1)..(start + batch_size)]

      # Information for user
      puts "*****Information******"
      puts "Using batch_size: #{batch_size}."
      puts "Running batch from index: #{start + 1 + 1} to index: #{start + data.count + 1}."
      puts "From UserID: #{(data.try(:first) || [])[0]} To UserID: #{(data.try(:last) || [])[0]}.\nRecord will be processed: #{data.count}."

      errors = []
      ActiveRecord::Base.transaction do
        data.each_with_index do |_row, index|
          # Convert row array and header as hash
          row =  Hash[[header, _row[0...header.count]].transpose]
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            # Check already have professional details
            profession = professions.find{|p| p.name.downcase == row["profession"].try(:downcase)}
            unless db_sadhak.professional_detail.present?
              professional_detail = db_sadhak.build_professional_detail(row.to_hash.except("UserID", "profession", "sub_profession").deep_merge({profession_id: profession.try(:id)}))
              raise Exception, "Some error occured while creating professional detail for id: #{row["UserID"].to_i}, errors: #{professional_detail.errors.full_messages}." unless professional_detail.save
            else
              professional_detail = db_sadhak.professional_detail
              raise Exception, "Some error occured while updating professional detail for id: #{row["UserID"].to_i}, errors: #{professional_detail.errors.full_messages}." unless professional_detail.update(row.to_hash.except("UserID", "profession", "sub_profession").deep_merge({profession_id: profession.try(:id)}))
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_spiritual_journey_details["sadhak.shivyog.com/Spiritual Journey/spiritual_journey.csv"]
  desc "Import spiritual journey details."
  task :import_spiritual_journey_details, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(:spiritual_journey).all

      months_mapper = {
        "1" => "january",
        "2" => "february",
        "3" => "march",
        "4" => "april",
        "5" => "may",
        "6" => "june",
        "7" => "july",
        "8" => "august",
        "9" => "september",
        "10" => "october",
        "11" => "november",
        "12" => "december"
      }

      errors = []
      ActiveRecord::Base.transaction do
        index = 2
        CSV.foreach(@file, :headers => true, :col_sep => "\t") do |row|
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            # Compute source of information
            # source_of_info = nil
            # csv_source_of_info = row["source_of_information"].try(:strip).try(:downcase)
            # ["Online", "TV", "Family / Friends", "Other"].each do |_source|
            #   if csv_source_of_info.present? and (csv_source_of_info.include?(_source.downcase) or _source.downcase.include?(csv_source_of_info))
            #     source_of_info = _source
            #     break
            #   end
            # end

            # source_of_info = "Other" unless source_of_info.present?

            # Compute sadhak event attended month
            month = nil
            csv_month = row["first_event_attended_month"].try(:strip).try(:downcase)
            months_mapper.each do |k, v|
              if csv_month.present? and (csv_month.include?(v) or v.include?(csv_month))
                month = k.to_i
                break
              end
            end
            month = (1..12).include?(month.to_i) ? month : nil

            # Compute sadhak event attended year
            year = row["first_event_attended_year"].to_s[/-?\d+/].to_i
            unless (1940..2016).include?(year)
              year = csv_month.to_s[/-?\d+/].to_i
            end
            year = (1940..2016).include?(year) ? year : nil

            # Check already have professional details
            unless db_sadhak.spiritual_journey.present?
              spiritual_journey = db_sadhak.build_spiritual_journey(row.to_hash.except("UserID", nil).deep_merge({"first_event_attended_month" => month, "first_event_attended_year" => year}))
              raise Exception, "Some error occured while creating spiritual_journey detail for id: #{row["UserID"].to_i}, errors: #{spiritual_journey.errors.full_messages}." unless spiritual_journey.save
            else
              spiritual_journey = db_sadhak.spiritual_journey
              raise Exception, "Some error occured while updating spiritual_journey detail for id: #{row["UserID"].to_i}, errors: #{spiritual_journey.errors.full_messages}." unless spiritual_journey.update(row.to_hash.except("UserID", nil).deep_merge({"first_event_attended_month" => month, "first_event_attended_year" => year}))
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index}-"
          index = index + 1
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_shivir_attended_details["sadhak.shivyog.com/Shivir Attended/shivir_attended.csv"]
  desc "Import shivir attended details."
  task :import_shivir_attended_details, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(:sadhak_profile_attended_shivirs).all

      months_mapper = {
        "1" => "january",
        "2" => "february",
        "3" => "march",
        "4" => "april",
        "5" => "may",
        "6" => "june",
        "7" => "july",
        "8" => "august",
        "9" => "september",
        "10" => "october",
        "11" => "november",
        "12" => "december"
      }

      errors = []
      ActiveRecord::Base.transaction do
        index = 2
        CSV.foreach(@file, :headers => true, :col_sep => "\t") do |row|
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Next if no data present in row except sadhak profile id i.e UserID
          data_present = []
          row.to_hash.except("UserID", nil).each do |k, v|
            data_present.push(v.present?)
          end
          next if data_present.uniq.count == 1 and not data_present.uniq.last

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            # Compute sadhak event attended month
            month = nil
            csv_month = row["month"].try(:strip).try(:downcase)
            months_mapper.each do |k, v|
              if csv_month.present? and (csv_month.include?(v) or v.include?(csv_month))
                month = k.to_i
              end
            end
            month = (1..12).include?(month.to_i) ? month : nil

            # Compute sadhak event attended year
            year = row["year"].to_s[/-?\d+/].to_i
            unless (1940..2016).include?(year)
              year = csv_month.to_s[/-?\d+/].to_i
            end
            year = (1940..2016).include?(year) ? year : nil

            shivir_attended = db_sadhak.sadhak_profile_attended_shivirs.build(row.to_hash.except("UserID", nil).deep_merge({"month" => month, "year" => year}))
            raise Exception, "Some error occured while creating shivir_attended detail for id: #{row["UserID"].to_i}, errors: #{shivir_attended.errors.full_messages}." unless shivir_attended.save
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index}-"
          index = index + 1
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_spiritual_practice_details["sadhak.shivyog.com/Spiritual Practice/spiritual_practice.csv"]
  task :import_spiritual_practice_details, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(spiritual_practice: [:spiritual_practice_frequent_sadhna_type_associations, :frequent_sadhna_types, :spiritual_practice_physical_exercise_type_associations, :physical_exercise_types, :spiritual_practice_shivyog_teaching_associations, :shivyog_teachings]).all

      errors = []
      ActiveRecord::Base.transaction do
        index = 2
        CSV.foreach(@file, :headers => true, :col_sep => "\t") do |row|
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Next if no data present in row except sadhak profile id i.e UserID
          data_present = []
          row.to_hash.except("UserID", nil).each do |k, v|
            data_present.push(v.present?)
          end
          next if data_present.uniq.count == 1 and not data_present.uniq.last

          # Modify data as per need.
          morning_sadha_duration_hours = row["morning_sadha_duration_hours"].try(:split, "-").try(:last)
          afternoon_sadha_duration_hours = row["afternoon_sadha_duration_hours"].try(:split, "-").try(:last)
          evening_sadha_duration_hours = row["evening_sadha_duration_hours"].try(:split, "-").try(:last)
          other_sadha_duration_hours = row["other_sadha_duration_hours"].to_s[/-?\d+/].to_i
          sadhana_frequency_days_per_week = row["sadhana_frequency_days_per_week"].try(:downcase)
          attributes_object = {
            morning_sadha_duration_hours: row["morning_sadha_duration_hours"].try(:split, "-").try(:last),
            afternoon_sadha_duration_hours: row["afternoon_sadha_duration_hours"].try(:split, "-").try(:last),
            evening_sadha_duration_hours: row["evening_sadha_duration_hours"].try(:split, "-").try(:last),
            other_sadha_duration_hours: row["other_sadha_duration_hours"].to_s[/-?\d+/].to_i,
            sadhana_frequency_days_per_week: row["sadhana_frequency_days_per_week"].try(:downcase)
          }

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            spiritual_practice = db_sadhak.spiritual_practice
            if spiritual_practice.present?
              raise Exception, "Some error occured while updating spiritual_practice detail for id: #{row["UserID"].to_i}, errors: #{spiritual_practice.errors.full_messages}." unless spiritual_practice.update(attributes_object)
            else
              spiritual_practice = db_sadhak.build_spiritual_practice(attributes_object)
              raise Exception, "Some error occured while creating spiritual_practice detail for id: #{row["UserID"].to_i}, errors: #{spiritual_practice.errors.full_messages}." unless spiritual_practice.save
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index}-"
          index = index + 1
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_frequent_sadhna_details["sadhak.shivyog.com/Spiritual Practice/frequent_sadhana.csv"]
  task :import_frequent_sadhna_details, [:filename, :start, :batch_size] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(spiritual_practice: [:spiritual_practice_frequent_sadhna_type_associations, :frequent_sadhna_types, :spiritual_practice_physical_exercise_type_associations, :physical_exercise_types, :spiritual_practice_shivyog_teaching_associations, :shivyog_teachings]).all

      # Collect frequent sadhan details
      frequent_sadhna_types = FrequentSadhnaType.all

      start = args[:start].present? ? args[:start].to_i : 0
      batch_size = args[:batch_size].present? ? args[:batch_size].to_i : 10000

      csv = CSV.read(@file, :col_sep => "\t")
      header = csv[0] - [nil]

      data = csv[(start + 1)..(start + batch_size)]

      # Information for user
      puts "*****Information******"
      puts "Using batch_size: #{batch_size}."
      puts "Running batch from index: #{start + 1 + 1} to index: #{start + data.count + 1}."
      puts "From UserID: #{(data.try(:first) || [])[0]} To UserID: #{(data.try(:last) || [])[0]}.\nRecord will be processed: #{data.count}."

      errors = []
      ActiveRecord::Base.transaction do
        data.each_with_index do |_row, index|
          # Convert row array and header as hash
          row =  Hash[[header, _row[0...header.count]].transpose]

          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Next if no data present in row except sadhak profile id i.e UserID
          data_present = []
          row.to_hash.except("UserID", nil).each do |k, v|
            data_present.push(v.present?)
          end
          next if data_present.uniq.count == 1 and not data_present.uniq.last

          # Find frequent sadhna type
          frequent_sadhna_type = frequent_sadhna_types.find{|f| f.name.downcase == row["frequent_sadhna_name"].try(:downcase)}

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            spiritual_practice = db_sadhak.spiritual_practice
            if spiritual_practice.present? and frequent_sadhna_type.present?
              association = spiritual_practice.spiritual_practice_frequent_sadhna_type_associations.build(frequent_sadhna_type_id: frequent_sadhna_type.id)
              raise Exception, "Some error occured while creating spiritual_practice frequent sadhna detail for id: #{row["UserID"].to_i}, errors: #{association.errors.full_messages}." unless association.save
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_physical_exercise_details["sadhak.shivyog.com/Spiritual Practice/physical_exercise.csv"]
  task :import_physical_exercise_details, [:filename, :start, :batch_size] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(spiritual_practice: [:spiritual_practice_frequent_sadhna_type_associations, :frequent_sadhna_types, :spiritual_practice_physical_exercise_type_associations, :physical_exercise_types, :spiritual_practice_shivyog_teaching_associations, :shivyog_teachings]).all

      # Collect frequent sadhan details
      physical_exercise_types = PhysicalExerciseType.all

      start = args[:start].present? ? args[:start].to_i : 0
      batch_size = args[:batch_size].present? ? args[:batch_size].to_i : 10000

      csv = CSV.read(@file, :col_sep => "\t")
      header = csv[0] - [nil]

      data = csv[(start + 1)..(start + batch_size)]

      # Information for user
      puts "*****Information******"
      puts "Using batch_size: #{batch_size}."
      puts "Running batch from index: #{start + 1 + 1} to index: #{start + data.count + 1}."
      puts "From UserID: #{(data.try(:first) || [])[0]} To UserID: #{(data.try(:last) || [])[0]}.\nRecord will be processed: #{data.count}."

      errors = []
      ActiveRecord::Base.transaction do
        data.each_with_index do |_row, index|
          # Convert row array and header as hash
          row =  Hash[[header, _row[0...header.count]].transpose]
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Next if no data present in row except sadhak profile id i.e UserID
          data_present = []
          row.to_hash.except("UserID", nil).each do |k, v|
            data_present.push(v.present?)
          end
          next if data_present.uniq.count == 1 and not data_present.uniq.last

          # Find frequent sadhna type
          physical_exercise_type = physical_exercise_types.find{|f| f.name.downcase == row["physical_exercise_name"].try(:downcase)}

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            spiritual_practice = db_sadhak.spiritual_practice
            if spiritual_practice.present? and physical_exercise_type.present?
              association = spiritual_practice.spiritual_practice_physical_exercise_type_associations.build(physical_exercise_type_id: physical_exercise_type.id)
              raise Exception, "Some error occured while creating spiritual_practice physical_exercise detail for id: #{row["UserID"].to_i}, errors: #{association.errors.full_messages}." unless association.save
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_shivyog_teaching_details["sadhak.shivyog.com/Spiritual Practice/shivyog_teaching.csv"]
  task :import_shivyog_teaching_details, [:filename, :start, :batch_size] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(spiritual_practice: [:spiritual_practice_frequent_sadhna_type_associations, :frequent_sadhna_types, :spiritual_practice_physical_exercise_type_associations, :physical_exercise_types, :spiritual_practice_shivyog_teaching_associations, :shivyog_teachings]).all

      # Collect frequent sadhan details
      shivyog_teachings = ShivyogTeaching.all

      start = args[:start].present? ? args[:start].to_i : 0
      batch_size = args[:batch_size].present? ? args[:batch_size].to_i : 10000

      csv = CSV.read(@file, :col_sep => "\t")
      header = csv[0] - [nil]

      data = csv[(start + 1)..(start + batch_size)]

      # Information for user
      puts "*****Information******"
      puts "Using batch_size: #{batch_size}."
      puts "Running batch from index: #{start + 1 + 1} to index: #{start + data.count + 1}."
      puts "From UserID: #{(data.try(:first) || [])[0]} To UserID: #{(data.try(:last) || [])[0]}.\nRecord will be processed: #{data.count}."

      errors = []
      ActiveRecord::Base.transaction do
        data.each_with_index do |_row, index|
          # Convert row array and header as hash
          row =  Hash[[header, _row[0...header.count]].transpose]
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Next if no data present in row except sadhak profile id i.e UserID
          data_present = []
          row.to_hash.except("UserID", nil).each do |k, v|
            data_present.push(v.present?)
          end
          next if data_present.uniq.count == 1 and not data_present.uniq.last

          # Find frequent sadhna type
          shivyog_teaching = shivyog_teachings.find{|f| f.name.downcase == row["shivyog_teaching_name"].try(:downcase)}

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            spiritual_practice = db_sadhak.spiritual_practice
            if spiritual_practice.present? and shivyog_teaching.present?
              association = spiritual_practice.spiritual_practice_shivyog_teaching_associations.build(shivyog_teaching_id: shivyog_teaching.id)
              raise Exception, "Some error occured while creating spiritual_practice shivyog_teaching detail for id: #{row["UserID"].to_i}, errors: #{association.errors.full_messages}." unless association.save
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_advance_profile_details["sadhak.shivyog.com/Advance Profile/advance_profile.csv"]
  task :import_advance_profile_details, [:filename] => :environment do |t, args|
    begin
      # Call other task to fetch file from S3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(:advance_profile).all
      photo_id_types = PhotoIdType.all
      address_proof_types = AddressProofType.all

      errors = []
      ActiveRecord::Base.transaction do
        index = 2
        CSV.foreach(@file, :headers => true, :col_sep => "\t") do |row|
          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}

          # Next if no data present in row except sadhak profile id i.e UserID
          data_present = []
          row.to_hash.except("UserID", nil).each do |k, v|
            data_present.push(v.present?)
          end
          next if data_present.uniq.count == 1 and not data_present.uniq.last

          # AdvanceProfile(id: integer, faith: string, any_legal_proceeding: boolean, attended_any_shivir: boolean, photograph_url: string, photograph_path: string, photo_id_proof_type: string, photo_id_proof_number: string, photo_id_proof_url: string, photo_id_proof_path: string, address_proof_type: string, address_proof_url: string, address_proof_path: string, sadhak_profile_id: integer, created_at: datetime, updated_at: datetime, address_proof_type_id: integer, photo_id_proof_type_id: integer)

          # Collect information
          photo_id_proof_type_id = photo_id_types.find{|p| p.name.downcase == row["photo_id_proof_type_id"].try(:downcase)}.try(:id)
          address_proof_type_id = address_proof_types.find{|a| a.name.downcase == row["address_proof_type_id"].try(:downcase)}.try(:id)

          attributes_object = row.to_hash.except("UserID", "photo_id_proof_type_id", "address_proof_type_id").deep_merge({"photo_id_proof_type_id" => photo_id_proof_type_id, "address_proof_type_id" => address_proof_type_id})

          # Check wether sadhak profile exist or not
          if db_sadhak.present?
            unless db_sadhak.advance_profile.present?
              advance_profile = db_sadhak.build_advance_profile(attributes_object)
              raise Exception, "Some error occured while creating advance_profile detail for id: #{row["UserID"].to_i}, errors: #{advance_profile.errors.full_messages}." unless advance_profile.save
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile does not exist in data base."})
          end
          print "#{index}-"
          index = index + 1
        end
      end
    rescue Exception => e
      puts e.backtrace
      binding.pry if Rails.env == "development"
    end
    # puts errors
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_sadhak_images["0/1/2"]
  desc "Update advance profile of sadhak (images)"
  task :import_sadhak_images, [:file_index] => :environment do |t, args|
    #  UserID, AddFile, PhotoFile, PhotoIDProofFile
    info_obj = [{
      address_prefix: "address",
      photo_id_prefix: "photoId101-20000",
      profile_photo_prefix: "profile_photo101-20000",
      file_name: "Users101-20000.csv"
    },
    {
      address_prefix: "address20001-40000",
      photo_id_prefix: "photoId20001-40000",
      profile_photo_prefix: "profile_photo20001-40000",
      file_name: "Users20001-40000.csv"
    },
    {
      address_prefix: " address40001-60000",
      photo_id_prefix: "photoId40001-60000",
      profile_photo_prefix: "profile_photo40001-60000",
      file_name: "Users40001-60000.csv"
    }]

    # Select the object from where data will be read
    selected_obj = info_obj[args[:file_index].to_i]

    bucket = Aws::S3::Bucket.new(ENV['REGISTRATION_PROFILE_PICTURES_BUCKET'])


    errors = []
    address_prefix = selected_obj[:address_prefix]
    profile_photo_prefix = selected_obj[:profile_photo_prefix]
    photo_id_prefix = selected_obj[:photo_id_prefix]
    bucket_name = "syittempbucket"
    not_available = ["", "NULL", "null", nil]

    # Call other task to fetch file from S3
    Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(selected_obj[:file_name])

    no_image_other = bucket.object("no_image_other.jpg")
    no_image_male = bucket.object("no_image_male.png")
    no_image_female = bucket.object("no_image_female.jpg")


    db_sadhaks = SadhakProfile.includes(:advance_profile).all
    begin
      # Read CSV file first
      ActiveRecord::Base.transaction do
        File.open(@file, "r").each_with_index do |line, index|
          next if index == 0

          # Collect info
          sadhak_profile_id, address_proof_name, profile_photo_name, photo_id_proof_name =  line.strip.split(",")

          # Collect file names
          address_file_name = address_proof_name.try(:split, "/").try(:last).try(:strip)
          profile_photo_file_name = profile_photo_name.try(:split, "/").try(:last).try(:strip)
          photo_id_file_name = photo_id_proof_name.try(:split, "/").try(:last).try(:strip)

          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == sadhak_profile_id.to_i}

          # Present then proceed else push to errors
          if db_sadhak.present?
            # Find its advance profile details
            if db_sadhak.advance_profile.present?
              advance_profile_photograph = db_sadhak.advance_profile.advance_profile_photograph
              advance_profile_identity_proof = db_sadhak.advance_profile.advance_profile_identity_proof
              advance_profile_address_proof = db_sadhak.advance_profile.advance_profile_address_proof

              # AdvanceProfileAddressProof
              unless advance_profile_address_proof.present?
                if not_available.include?(address_file_name)
                  # Not available
                  image = Image.new({:name => no_image_other.key, :s3_url => no_image_other.public_url.to_s, :s3_path => no_image_other.key.to_s, :is_secure => false, :s3_bucket => no_image_other.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfileAddressProof"})
                  errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                else
                  # Available
                  s3_file = Aws::S3::Bucket.new(bucket_name).object("#{address_prefix}/#{address_file_name}")

                  # Exist
                  if s3_file.exists?
                    image = Image.new({:name => address_file_name, :s3_url => s3_file.public_url.to_s, :s3_path => s3_file.key.to_s, :is_secure => false, :s3_bucket => s3_file.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfileAddressProof"})
                    errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                  else
                    # Not exist
                    image = Image.new({:name => no_image_other.key, :s3_url => no_image_other.public_url.to_s, :s3_path => no_image_other.key.to_s, :is_secure => false, :s3_bucket => no_image_other.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfileAddressProof"})
                    errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                  end
                end
              end

              # AdvanceProfilePhotograph
              unless advance_profile_photograph.present?
                no_image = db_sadhak.gender == "male" ? no_image_male : db_sadhak.gender == "female" ? no_image_female : no_image_other
                if not_available.include?(profile_photo_file_name)
                  # Not available
                  image = Image.new({:name => no_image.key, :s3_url => no_image.public_url.to_s, :s3_path => no_image.key.to_s, :is_secure => false, :s3_bucket => no_image.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfilePhotograph"})
                  errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                else
                  # Available
                  s3_file = Aws::S3::Bucket.new(bucket_name).object("#{profile_photo_prefix}/#{profile_photo_file_name}")

                  # Exist
                  if s3_file.exists?
                    image = Image.new({:name => address_file_name, :s3_url => s3_file.public_url.to_s, :s3_path => s3_file.key.to_s, :is_secure => false, :s3_bucket => s3_file.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfilePhotograph"})
                    errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                  else
                    # Not exist
                    image = Image.new({:name => no_image.key, :s3_url => no_image.public_url.to_s, :s3_path => no_image.key.to_s, :is_secure => false, :s3_bucket => no_image.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfilePhotograph"})
                    errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                  end
                end
              end

              # AdvanceProfileIdentityProof
              unless advance_profile_identity_proof.present?
                if not_available.include?(photo_id_file_name)
                  # Not available
                  image = Image.new({:name => no_image_other.key, :s3_url => no_image_other.public_url.to_s, :s3_path => no_image_other.key.to_s, :is_secure => false, :s3_bucket => no_image_other.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfileIdentityProof"})
                  errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                else
                  # Available
                  s3_file = Aws::S3::Bucket.new(bucket_name).object("#{photo_id_prefix}/#{photo_id_file_name}")

                  # Exist
                  if s3_file.exists?
                    image = Image.new({:name => photo_id_file_name, :s3_url => s3_file.public_url.to_s, :s3_path => s3_file.key.to_s, :is_secure => false, :s3_bucket => s3_file.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfileIdentityProof"})
                    errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                  else
                    # Not exist
                    image = Image.new({:name => no_image_other.key, :s3_url => no_image_other.public_url.to_s, :s3_path => no_image_other.key.to_s, :is_secure => false, :s3_bucket => no_image_other.bucket.name, :imageable_id => db_sadhak.advance_profile.id, :imageable_type => "AdvanceProfileAddressProof"})
                    errors.push({sadhak_profile_id: sadhak_profile_id, image_error: image.errors.full_messages}) unless image.save
                  end
                end
              end
            else
              errors.push({sadhak_profile_id: sadhak_profile_id, message: "Advance profile does not exist for sadhak."})
            end
          else
            errors.push({sadhak_profile_id: sadhak_profile_id, message: "Sadhak profile not found in data base."})
          end
          print "#{index+1}-"
        end
      end
    rescue Exception => e
      puts "Exception occured: #{e.message}."
      binding.pry if Rails.env == "development"
    end
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_aspect_of_lives["sadhak.shivyog.com/Aspect of life/aspect_of_life.csv"]
  require 'csv'
  desc "Update aspect of lives"
  task :import_aspect_of_lives, [:filename] => :environment do |t, args|
    # Collect all sadhak profiles with aspects of life and feedbacks
    db_sadhaks = SadhakProfile.includes(aspects_of_life: [:aspect_feedbacks]).all

    errors = []
    success = []
    begin
      # Load file from s3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      ActiveRecord::Base.transaction do
        index = 2
        CSV.foreach(@file, :headers => true, :col_sep => "\t") do |row|
          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}
          if db_sadhak.present?
            # If no aspect of life found then create it
            unless db_sadhak.aspects_of_life.present?
              # Build aspect of life
              aspects_of_life = db_sadhak.build_aspects_of_life

              # Push error if not savable
              errors.push({sadhak_profile_id: row["UserID"].to_i, message: aspects_of_life.errors.full_messages}) unless aspects_of_life.save

              next unless aspects_of_life.errors.empty?

              # Raise exception if there is any error
              # raise Exception, aspects_of_life.errors.full_messages.first unless aspects_of_life.errors.empty?
            end

            # Update aspect feedbacks
            db_sadhak.aspects_of_life.aspect_feedbacks.each do |aspect_feedback|

              # Collect rating from CSV
              rating_before = row[aspect_feedback.aspect_type + "B"].to_i
              rating_after = row[aspect_feedback.aspect_type + "A"].to_i

              # Logic to reduce rating if greater than 4
              rating_before = (((rating_before * 10) * 20)/100).ceil
              rating_after = (((rating_after * 10) * 20)/100).ceil

              rating_before = (0..20).include?(rating_before) ? rating_before : 0
              rating_after = (0..20).include?(rating_after) ? rating_after : 0

              # Push error if not savable
              errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Error in updating aspect feedback (#{aspect_feedback.aspect_type}) of sadhak id: #{row["UserID"].to_i}."}) unless aspect_feedback.update(rating_before: rating_before, rating_after: rating_after)

              # Raise error if not able to update
              # raise Exception, "Error in updating aspect feedback (#{aspect_feedback.aspect_type}) of sadhak id: #{row["UserID"].to_i}." unless aspect_feedback.update(rating_before: rating_before, rating_after: rating_after)
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile not found in data base."})
          end
          print "#{index}-"
          index += 1
        end
      end
    rescue Exception => e
      puts "Exception occured: #{e.message}."
      binding.pry if Rails.env == "development"
    end
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:import_sadhak_passwords["sadhak.shivyog.com/Sadhak Profiles/sadhak_passwords.csv"]
  desc "Import sadhak passwords."
  task :import_sadhak_passwords, [:filename, :start, :batch_size] => :environment do |t, args|

    errors = []
    begin
      # Load file from s3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3_password'].invoke(args[:filename])

      # Collect all sadhak profiles with aspects of life and feedbacks
      db_sadhaks = SadhakProfile.includes(:user).all

      start = args[:start].present? ? args[:start].to_i : 0
      batch_size = args[:batch_size].present? ? args[:batch_size].to_i : 10000

      # csv = CSV.read(@file, :col_sep => ",")
      csv = @data
      header = csv[0] - [nil]

      data = csv[(start + 1)..(start + batch_size)]

      # Information for user
      puts "*****Information******"
      puts "Using batch_size: #{batch_size}."
      puts "Running batch from index: #{start + 1 + 1} to index: #{start + data.count + 1}."
      puts "From UserID: #{(data.try(:first) || [])[0]} To UserID: #{(data.try(:last) || [])[0]}.\nRecord will be processed: #{data.count}."

      ActiveRecord::Base.transaction do
        data.each_with_index do |_row, index|
          # Convert row array and header as hash
          row =  Hash[[header, _row[0...header.count]].transpose]

          db_sadhak = db_sadhaks.find{|s| s.id == row["UserID"].to_i}
          if db_sadhak.present?
            user = db_sadhak.user
            if user.present?
              if user.last_sign_in_at.nil? and row["password"].present?
                user.password = row["password"]
                raise "#{user.errors.full_messages}" unless user.save(validate: false)
              end
            else
              errors.push({sadhak_profile_id: row["UserID"].to_i, message: "No associated user found."})
            end
          else
            errors.push({sadhak_profile_id: row["UserID"].to_i, message: "Sadhak profile not found in data base."})
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts "Exception occured: #{e.message}."
      binding.pry if Rails.env == "development"
    end
    binding.pry if Rails.env == "development"
    puts errors
  end

  # rake import_sadhak_profile_03052015:upload_sadhak_images_s3["./extra/s3/photoId/Users101-20000.txt","photoId101-20000","UserFiles"]
  # rake import_sadhak_profile_03052015:upload_sadhak_images_s3["./extra/s3/photoId/Users20001-40000.txt","photoId20001-40000","UserFiles"]
  # rake import_sadhak_profile_03052015:upload_sadhak_images_s3["./extra/s3/photoId/Users40001-60000.txt","photoId40001-60000","UserFiles"]
  require 'open-uri'
  desc "Import sadhak images data"
  task :upload_sadhak_images_s3, [:filename, :prefix, :folder_name] => :environment do |t, args|
    #  UserID, SYID, UserName, FName, LName, AddFile, PhotoFile, PhotoIDProofFile

    errors = []
    total_uploads = []
    new_errors = []
    base_url = "http://sadhak.shivyog.com"
    folder_name = args[:folder_name] #"UserFiles"
    prefix = args[:prefix]
    bucket_name = "syittempbucket"

    raise Exception, "Please provide args." unless args[:folder_name].present? and args[:prefix].present?

    # file_name = "14-03-2015-02-16office_cover_crop.jpg"
    File.open(args[:filename], "r").each_line.with_index do |line, index|
      begin
        line.delete!("\n")
        # next if existing.include?("#{prefix}/#{line}")
        url = URI.encode("#{base_url}/#{folder_name}/#{line}", '[]\ () + ~ & @')
        file = open(url)
        s3_file = Attachment.upload_file(file_name: "#{prefix}/#{line}", content: file, is_secure: false, bucket_name: bucket_name, file_type: file.content_type)
        total_uploads.push(s3_file) if s3_file.exists?
      rescue Exception => e
        errors.push({line: line, message: e.message, url: url})
      end
      print "#{index}-"
    end

    binding.pry if Rails.env == "development"
    # puts errors
    # puts total_uploads

    errors.collect{|e| e[:line]}.each_with_index do |line, index|
      begin
        file = open(URI.encode("#{base_url}/#{folder_name}/#{line}", '[]\ () + ~ & @ ? # `'))
        s3_file = Attachment.upload_file(file_name: "#{prefix}/#{line}", content: file, is_secure: false, bucket_name: bucket_name, file_type: file.content_type)
        total_uploads.push(s3_file) if s3_file.exists?
      rescue Exception => e
        new_errors.push({line: line, message: e})
      end
      print "#{index}-"
    end

    binding.pry if Rails.env == "development"
  end

  # rake import_sadhak_profile_03052015:update_guru_name_and_orgname["data_migrations/SV4_SYID_Update_Form_sept_27_2016.xlsx"]
  desc 'Update name of guru and org name in sadhak profile'
  task :update_guru_name_and_orgname, [:filename, :start, :batch_size] => :environment do |t, args|
    include CommonHelper
    errors = []
    begin
      # Load file from s3
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

      start = args[:start].present? ? args[:start].to_i : 0
      batch_size = args[:batch_size].present? ? args[:batch_size].to_i : 10000

      data_obj = read_xlsx(@file)

      # csv = CSV.read(@file, :col_sep => ",")
      csv = data_obj[:content]
      header = data_obj[:header]

      data = csv[(start)..(start + batch_size)]

      db_sadhaks = SadhakProfile.where(id: data.collect{|d| d[:syid]})

      # Information for user
      puts '*****Information******'
      puts "Using batch_size: #{batch_size}."
      puts "Running batch from index: #{start + 1} to index: #{start + data.count}."
      puts "From UserID: #{(data.try(:first) || {})[:syid]} To UserID: #{(data.try(:last) || {})[:syid]}.\nRecord will be processed: #{data.size}."
      ActiveRecord::Base.transaction do
        data.each_with_index do |_row, index|
          db_sadhak = db_sadhaks.find{|s| s.id === _row[:syid].to_i}
          if db_sadhak.present?
            unless db_sadhak.update(name_of_guru: _row[:name_of_guru], spiritual_org_name: _row[:spiritual_org_name])
              errors.push({sadhak_profile_id: _row[:syid].to_i, message: db_sadhak.errors.full_messages})
            end
          else
            errors.push({sadhak_profile_id: _row[:syid].to_i, message: 'Sadhak profile not found in data base.'})
          end
          print "#{index + 1}-"
        end
      end
    rescue Exception => e
      puts "Exception occured: #{e.message}."
      binding.pry if Rails.env == 'development'
    end
    binding.pry if Rails.env == 'development'
    puts errors
  end

  desc 'Read file from S3'
  task :read_file_from_s3, [:filename] => :environment do |t, args|
    bucket = Aws::S3::Bucket.new('syittempbucket')
    s3_file = bucket.object(args[:filename])
    @file = open(s3_file.public_url.to_s)
  end

  desc 'Read file from S3 - password'
  task :read_file_from_s3_password, [:filename] => :environment do |t, args|
    bucket = Aws::S3::Bucket.new('syittempbucket')
    s3_file = bucket.object(args[:filename])
    @data = []
    begin
      open(s3_file.public_url.to_s) do |f|
        @data = CSV.parse f
      end
    rescue Exception => e
      puts "#{e.message}"
    end
  end
end
