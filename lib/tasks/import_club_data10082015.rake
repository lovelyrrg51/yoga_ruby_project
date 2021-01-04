namespace :import_club_data10082015 do
  # rake import_club_data10082015:import_club_data['forum_with_venue_details.csv'], ['forum_with_address_194_onwards.csv'] 
 desc "Import club data"
  task :import_club_data, [:filename] => :environment do |t, args|
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
      club_name1, name2, name3, venue_id, country_id, state_id, city_id, pincode, street_address, old_forum_id =  line.strip.split(",")
      # puts club_name, venue_id, country_id, state_id, city_id, street_address, pincode, index
      club_name = "#{club_name1}  #{name2} #{name3}"
      # print club_name, venue_id, country_id, state_id, city_id, pincode, street_address, old_forum_id, "\n"
      @sy_club = SyClub.find_or_create_by(name: club_name, old_forum_id: old_forum_id, old_venue_id: venue_id)
      # valiate address
      @country = DbCountry.find(country_id[/-?\d+/])
      @state = @country.states.where(id: state_id[/-?\d+/]).first if @country.present?
      if pincode.present?
        @pincode = pincode
      else
        pincode = nil
      end
      if city_id[/-?\d+/] != '-1'
        @city_id = city_id
      else
        @city_id = nil
      end
      
      # save club address
      if @sy_club.present?
        if @sy_club.address.present?
          @club_address = @sy_club.address.update_attributes(addressable_type: 'SyClub', addressable_id: @sy_club.id, country_id: @country.id, state_id: @state.id, city_id: @city_id, first_line: street_address, postal_code: @pincode)
          puts @sy_club.name, index, "address_updated"
        else
          @club_address = @sy_club.create_address(addressable_type: 'SyClub', addressable_id: @sy_club.id, country_id: @country.id, state_id: @state.id, city_id: @city_id, first_line: street_address, postal_code: @pincode)
          puts @sy_club.name
        end
      else
        puts 'error in save', "#{index}"
      end
    end
  end
  
  task :add_old_forum_id, [:filename] => :environment do |t, args| #filename old_forum_id_with_venue_id.csv
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
      forum_id, venue_id =  line.strip.split(",")
      @sy_club = SyClub.where(old_venue_id: venue_id).last
      @sy_club.update_attribute("old_forum_id", forum_id)
      puts "updated"
    end
  end
  
  task :add_organiser_to_forum, [:filename] => :environment do |t, args| #filename forum_organiser_data.csv
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
      forum_id, user_id, syid, role_id, role_name =  line.strip.split(",")
      case  role_id
        when "3"
          @role_id = 1
        when "4"
          @role_id = 2
        when "5"
          @role_id = 3
        else
          @role_id = nil
      end
      if user_id.present?
        @sy_club = SyClub.where(old_forum_id: forum_id).last
        @sy_club_sp_associtaions = SyClubSadhakProfileAssociation.where(sy_club_id: @sy_club.id, sadhak_profile_id: user_id, sy_club_user_role_id: @role_id) if @sy_club.present?
        if @sy_club_sp_associtaions.count > 0
          puts "already exist"
        else
          @sy_club_associtaion = SyClubSadhakProfileAssociation.new(sy_club_id: @sy_club.id, sadhak_profile_id: user_id, sy_club_user_role_id: @role_id) if @sy_club.present?
          if @sy_club_associtaion.save!
            puts "organiser associated"
          else
            puts "error"
          end
        end
      else
        puts "no member found"
      end
    end
  end
  
  task :forum_member_data_transfer => :environment do |t, args| 
    SyClubSadhakProfileAssociation.where(sy_club_user_role_id: nil).each do |association|
      @member = SyClubMember.find_or_create_by(sadhak_profile_id: association.sadhak_profile_id, sy_club_id: association.sy_club_id, status: association.status, club_joining_date: association.club_joining_date, guest_email: association.guest_email)
      if @member.present?
        puts "Data transfer successfully"
      else
        puts "error"
      end
      # if @member.present?
      #   @member.update_attributes(status: association.status, club_joining_date: association.club_joining_date, guest_email: association.guest_email)
      #   puts "Saved successfully"
      # else
      #   puts "Error in updating"
      # end
    end
  end
  
  desc "Task description"
  task :add_non_existing_club_members => :environment do
    list = [["2505", "537"], ["18112", "573"], ["9832", "424"], ["2059", "582"], ["2746", "576"], ["2799", "559"], ["2841", "567"], ["10053", "599"], ["3771", "575"], ["12458", "423"], ["12368", "423"], ["40331", "573"], ["7919", "567"], ["19297", "580"], ["9536", "459"], ["2533", "426"], ["18100", "576"], ["18700", "566"], ["17307", "467"], ["39717", "575"], ["935", "511"], ["9100", "500"], ["19803", "594"], ["7430", "507"], ["2871", "543"], ["26663", "644"], ["3156", "455"], ["18002", "466"], ["380", "449"], ["5213", "542"], ["6824", "542"], ["926", "511"], ["4870", "544"], ["6512", "470"], ["17735", "470"], ["10044", "467"], ["40569", "555"], ["3710", "555"], ["22213", "588"], ["11233", "624"], ["718", "451"], ["2717", "469"], ["2575", "600"], ["6441", "454"], ["16036", "615"], ["2065", "585"], ["3062", "624"], ["21444", "595"], ["3903", "569"], ["3922", "569"], ["329", "440"], ["18811", "606"], ["2788", "564"], ["501", "442"], ["18199", "554"], ["3435", "431"], ["11897", "459"], ["11418", "507"], ["43902", "615"], ["2694", "601"], ["44352", "612"], ["2646", "612"], ["12408", "585"], ["45804", "425"], ["9219", "585"], ["10708", "424"], ["17563", "466"], ["16558", "531"], ["7502", "498"], ["10284", "431"], ["8315", "438"], ["2012", "451"], ["19632", "605"], ["18102", "575"], ["8926", "552"], ["18598", "606"], ["25676", "611"], ["40468", "555"], ["3200", "588"], ["105", "492"], ["17273", "470"], ["10623", "582"], ["5851", "509"], ["3474", "616"], ["10544", "578"], ["40021", "535"], ["964", "511"], ["18337", "468"], ["44250", "616"], ["43706", "605"], ["8945", "509"], ["2199", "492"], ["5227", "606"], ["10878", "439"], ["26503", "516"], ["43024", "425"], ["25226", "438"], ["28481", "438"], ["14396", "538"], ["5468", "542"], ["5161", "440"], ["8598", "602"], ["22734", "574"], ["11594", "564"], ["3997", "645"], ["3554", "561"], ["8307", "428"], ["11568", "624"], ["8322", "496"], ["8273", "494"], ["14103", "514"], ["41762", "428"], ["2819", "520"], ["32385", "458"], ["37686", "636"], ["8751", "494"], ["14046", "432"], ["18297", "466"], ["40439", "475"], ["8381", "643"], ["13580", "449"], ["42248", "479"], ["41514", "514"], ["7121", "544"], ["32258", "631"], ["14925", "423"], ["7851", "520"], ["12591", "603"], ["15087", "552"], ["4251", "593"], ["37005", "478"], ["43437", "602"], ["12290", "503"], ["14009", "592"], ["15266", "501"], ["29788", "625"], ["5815", "569"], ["3772", "662"], ["23375", "467"], ["6689", "431"], ["43715", "602"], ["11595", "554"], ["10090", "568"], ["2712", "428"], ["18916", "462"], ["3846", "568"], ["2172", "501"], ["4024", "661"], ["18284", "510"], ["19031", "475"], ["41945", "475"], ["8616", "506"], ["17443", "567"], ["6180", "506"], ["4170", "671"], ["19494", "647"], ["14056", "647"], ["23598", "647"], ["3466", "662"], ["42804", "532"], ["19410", "566"], ["7616", "498"], ["19538", "538"], ["37032", "442"], ["1930", "442"], ["8561", "659"], ["7034", "502"], ["7422", "502"], ["17459", "462"], ["41553", "432"], ["2223", "659"], ["14516", "544"], ["11593", "592"], ["43900", "615"], ["43708", "607"], ["31845", "613"], ["14041", "503"], ["7116", "582"], ["41510", "516"], ["7405", "671"], ["7040", "496"], ["44277", "612"], ["3", "657"], ["12130", "667"], ["30964", "473"], ["6390", "663"], ["41401", "663"], ["5930", "663"], ["43852", "638"], ["11456", "494"], ["20707", "527"], ["5218", "502"], ["26320", "514"], ["10536", "476"], ["4226", "586"], ["25107", "496"], ["38884", "498"], ["252", "533"], ["2278", "607"], ["19354", "476"], ["37001", "611"], ["13377", "500"], ["10164", "493"], ["113", "657"], ["29546", "640"], ["28532", "465"], ["43689", "607"], ["255", "533"], ["23559", "479"], ["36815", "621"], ["2902", "636"], ["28262", "578"], ["3935", "499"], ["7035", "499"], ["261", "515"], ["14422", "424"], ["39415", "443"], ["11257", "508"], ["37208", "462"], ["42579", "580"], ["42558", "580"], ["11927", "499"], ["5689", "541"], ["19574", "566"], ["10947", "532"], ["16556", "531"], ["7243", "454"], ["40145", "536"], ["6232", "439"], ["24599", "439"], ["44134", "603"], ["18650", "589"], ["2111", "595"], ["27321", "586"], ["2491", "590"], ["9246", "554"], ["544", " 430"], ["6656", "493"], ["6552", "643"], ["261", " 515"], ["44216", "613"], ["21682", "537"], ["23984", "568"], ["13", " 653"], ["72825", "653"], ["16570", "465"], ["31896", "668"], ["113", " 657"], ["8504", "455"], ["12041", "465"], ["7896", "570"], ["24529", "570"], ["24527", "570"], ["1622", "455"], ["13786", "449"], ["12326", "505"], ["40879", "564"], ["17197", "673"], ["16021", "507"], ["11619", "551"], ["11998", "446"], ["11281", "667"], ["7909", "679"], ["9617", "464"], ["39833", "573"], ["15326", "426"], ["20337", "426"], ["23137", "508"], ["37940", "430"], ["38051", "477"], ["22553", "586"], ["4977", "614"], ["2795", "603"], ["18647", "589"], ["43907", "638"], ["6568", "506"], ["43896", "638"], ["2492", "508"], ["2774", "552"], ["25487", "640"], ["24285", "536"], ["5898", "643"], ["6492", "533"], ["23165", "510"], ["35594", "668"], ["6544", "516"], ["43728", "608"], ["3525", "658"], ["39385", "446"], ["27729", "446"], ["11651", "635"], ["15165", "553"], ["9902", "679"], ["10316", "679"], ["18874", "679"], ["16040", "693"], ["42134", "473"], ["16991", "429"], ["4883", "429"], ["25472", "687"], ["37266", "636"], ["26842", "445"], ["19709", "445"], ["5417", "614"], ["7420", "658"], ["44094", "609"], ["2382", "493"], ["16940", "592"]]
    list.each do |s_id, c_id|
      member = SyClubMember.find_or_create_by(sadhak_profile_id: s_id, sy_club_id: c_id)
      if member.present?
        member.update_attributes(status: 1, club_joining_date: Date.current, sy_club_validity_window_id: 1, guest_email: member.sadhak_profile.email)
        puts "#{member.sadhak_profile_id},#{member.sy_club_id}"
      else
        puts "Error in creating"
      end
    end
  end
    
end