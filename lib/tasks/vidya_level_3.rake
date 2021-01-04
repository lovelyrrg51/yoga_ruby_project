namespace :vidya_level_3 do
#   rake vidya_level_3:club_with_members_count[vidya_level_pre_prod.csv,<YOUR-EventId>]
  desc "Migrating shree vidya level 3 with their applicants."
  task :migrate_vidya_level3_data1, [:filename] => :environment do |t, args|
    errors = []
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
        sadhak_profile_id, syid, price, seating_category_id, seating_association_id =  line.strip.split(",")
        event_id =  522#, for dev same on pre-prod
        puts sadhak_profile_id, syid, price, seating_category_id, seating_association_id, event_id
        @sadhak_profile = SadhakProfile.where(id: sadhak_profile_id).last
        if @sadhak_profile.present? and @sadhak_profile.email.present?
          @guest_email = @sadhak_profile.email
        end
        @event_order = EventOrder.new(status: 'success', total_amount: price, event_id: event_id, guest_email: @guest_email, is_guest_user: true)
      if @event_order.save!
          puts "event_order ID"
          puts @event_order.id
        @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: seating_category_id, event_seating_category_association_id: seating_association_id, price: price)
        if @event_order_line_item.save!
            puts "event_order_line_item ID"
            puts @event_order_line_item.id
            @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: seating_association_id, event_id: event_id, event_order_line_item_id: @event_order_line_item.id)
            if @event_registration.save!
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
    if errors.count > 0
      puts errors
    else
      puts "No error found"
    end
  end

# final Copy of Srividya Malaysia1 2015 list
  desc "Migrating shree vidya level 3 with their applicants."
  task :migrate_vidya_level3_missing_syid_profile, [:filename, :event_id] => :environment do |t, args|
    errors = []
    missing_syids = []
    existing_profiles = []
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
        sadhak_profile_id, syid, price, seating_category_id, seating_association_id, name, mobile =  line.strip.split(",")
      if sadhak_profile_id == "N/A"
        if mobile.present?
          mobile = mobile.split(' ')
        end
        missing_syids.push([name, syid, mobile[1]])
        if name.present? and mobile[0].present?
          name = name.split(' ')
          sadhak_profile = SadhakProfile.where("LOWER(first_name) = ? and mobile = ?", name[0].downcase, mobile[1])
          # sadhak_profile = SadhakProfile.where( "mobile = ? OR phone = ? OR first_name = ?", mobile[1], mobile[1], name[0])
          if sadhak_profile.present?
            existing_profiles.push(sadhak_profile.pluck(:syid, :first_name, :mobile))
          end
        end      
        puts sadhak_profile_id, syid, price, seating_category_id, seating_association_id, name, mobile[1]
      else
        event_id =  "#{args[:event_id]}"#4#, for dev same on pre-prod
        missing_profiles = 
        puts sadhak_profile_id, syid, price, seating_category_id, seating_association_id, event_id
        if sadhak_profile_id.present?
          @sadhak_profile = SadhakProfile.where(id: sadhak_profile_id).last
          if @sadhak_profile.present? and @sadhak_profile.email.present?
            @guest_email = @sadhak_profile.email
          else

          end
        end
        @event_order = EventOrder.new(status: 'success', total_amount: price, event_id: event_id, guest_email: @guest_email, is_guest_user: true)
        if @event_order.save!
            puts "event_order ID"
            puts @event_order.id
          @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: seating_category_id, event_seating_category_association_id: seating_association_id, price: price)
          if @event_order_line_item.save!
              puts "event_order_line_item ID"
              puts @event_order_line_item.id
              @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: seating_association_id, event_id: event_id, event_order_line_item_id: @event_order_line_item.id)
              if @event_registration.save!
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
    end
    if errors.count > 0
        puts errors
    else
      puts "No error found"
    end
    puts "Missing SYIDS count"
    puts missing_syids.count
    puts "##missing profiles****"
    puts missing_syids.to_s
    puts "existing_profiles count"
    puts existing_profiles.count
    puts "existing_profiles"
    puts existing_profiles
    # begin
    #   file = File.open("./Malaysia_Without_SYID-Script.csv", "w")
    #   file.write(existing_profiles) 
    # rescue IOError => e
    #   #some error occur, dir not writable etc.
    # ensure
    #   file.close unless file.nil?
    # end
  end
end