namespace :goa_sv3 do
  # rake goa_sv3:goa_find_syid["./extra/SV3_Data_Migration/Goa_Without_SYID.csv"]
  desc "Migrating shree vidya level 3 with their applicants."
  task :goa_find_syid, [:filename] => :environment do |t, args|
    found_records = "NAME,MOBILE,SYIDS\n"
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
      print "#{index+1}-"
      found_syids = []
      full_name, mobile = line.strip.split(",")
      extracted_line = full_name + "," + mobile
      # puts extracted_line
      splitted_name = full_name.split(" ")
      # puts "#{index+1}:#{full_name}:#{splitted_name.count}"`
      # next
      profiles = []
      m_profiles = []
      if splitted_name.count == 3
        first_name, middle_name, last_name = full_name.strip.split(" ")
        profiles = SadhakProfile.where("UPPER(first_name) LIKE ? AND UPPER(middle_name) LIKE ? AND UPPER(last_name) LIKE ?", "%#{first_name}%", "%#{middle_name}%", "%#{last_name}%")
      elsif splitted_name.count == 2
        first_name, last_name = full_name.strip.split(" ")
        profiles = SadhakProfile.where("UPPER(first_name) LIKE ? AND UPPER(last_name) LIKE ?", "%#{first_name}%", "%#{last_name}%")
      end
      if profiles.count == 0
        first_name = full_name.strip.split(" ")
        profiles = SadhakProfile.where("UPPER(first_name) LIKE ?", "%#{first_name}%")
      end
      if profiles.count > 0
        if mobile.present? and !mobile.downcase.include?("no")
          m_profiles = profiles.where("mobile LIKE ? OR phone LIKE ?", "%#{mobile}%", "%#{mobile}%")
        end
      end
      if m_profiles.count == 1
        found_syids.push(m_profiles.last.syid)
      elsif m_profiles.count > 0
        found_syids = m_profiles.collect{|sp| sp.syid}
      else
        found_syids = []      
      end
      # Perform next try with mobile only
      if found_syids.count == 0
        m_profiles = SadhakProfile.where("mobile LIKE ? OR phone LIKE ?", "%#{mobile}%", "%#{mobile}%")
        if m_profiles.count == 1
          found_syids.push(m_profiles.last.syid)
        elsif m_profiles.count > 0
          found_syids = m_profiles.collect{|sp| sp.syid}
        else
          found_syids = profiles.collect{|sp| sp.syid}
        end
      end
      found_records += ("#{full_name},#{mobile}," + found_syids.join("-") + "\n")
      # found_records += ("#{full_name},#{mobile}," + found_syids.to_sentence(words_connector:',', two_words_connector: ',', last_word_connector: ',') + "\n")
    end
    puts "success"
    begin
      file = File.open("./extra/SV3_Data_Migration/Goa_Without_SYID-Script.csv", "w")
      file.write(found_records) 
    rescue IOError => e
      #some error occur, dir not writable etc.
    ensure
      file.close unless file.nil?
    end
  end

  # rake goa_sv3:migrate_sv3_data["./extra/SV3_Data_Migration/Goa_Without_SYID.csv","100","4","77","525"]
  task :migrate_sv3_data, [:filename, :price, :seating_category_id, :seating_association_id, :event_id] => :environment do |t, args|
    begin
      errors = []
      sadhak_errors = []
      ActiveRecord::Base.transaction do
        File.open("#{args[:filename]}", "r").each_with_index do |line, index|
          # print "#{index+1}"
          sadhak_profile_id, price, seating_category_id, seating_association_id =  line.strip.split(",")
          price = args[:price]
          seating_category_id = args[:seating_category_id]
          seating_association_id = args[:seating_association_id]
          event_id =  args[:event_id]
          # puts "#{sadhak_profile_id},#{price},#{seating_category_id},#{seating_association_id},#{event_id}\n"
          # next
          @sadhak_profile = SadhakProfile.where(id: sadhak_profile_id).last
          if @sadhak_profile.present? and @sadhak_profile.email.present?
            @guest_email = @sadhak_profile.email
          end
          begin
            ActiveRecord::Base.transaction do
              @event_order = EventOrder.new(status: 'success', total_amount: price, event_id: event_id, guest_email: @guest_email, is_guest_user: true)
              if @event_order.save
                puts "event_order ID"
                puts @event_order.id
                @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: seating_category_id, event_seating_category_association_id: seating_association_id, price: price)
                if @event_order_line_item.save
                  puts "event_order_line_item ID"
                  puts @event_order_line_item.id
                  @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: seating_association_id, event_id: event_id, event_order_line_item_id: @event_order_line_item.id)
                  if @event_registration.save
                    puts "event registration created successfully"
                    puts @event_registration.id
                  else
                    errors.push(["event registration error", @event_registration.id].to_s)
                    puts "event registration error"
                    puts @event_registration.id  
                  end
                else
                  errors.push(["Error in line item", @event_order_line_item.id].to_s)
                  puts "Error in line item"
                  puts @event_order_line_item.id
                end
              else
                errors.push(["Error in event order", @event_order.id].to_s)
                puts "Error in event order"
                puts @event_order.id        
              end
            end
          rescue Exception => e
            puts e.backtrace
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    if errors.count > 0
      puts errors
    else
      puts "No error found"
    end
  end
end