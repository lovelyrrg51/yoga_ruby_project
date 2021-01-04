namespace :sy_forum_lat_lng_update do
  desc 'Update Sy forum lat lng'
  require 'geocoder'
  task do_update_sy_forum_lat_lng: :environment do
  	errors = []
  	caputred = []
    SyClub.includes({ address: [:db_city, :db_state, :db_country] }).all.each_with_index do |sy_club, index|
    	if sy_club.address.present?				
				if sy_club.address.lat.nil? or sy_club.address.lng.nil?
					key = "#{sy_club.address.city_id},#{sy_club.address.state_id},#{sy_club.address.country_id}"
	    		found = caputred.find{|k| key == k[0] }
	    		if found.present?
	    			result = found
	    		else
	    			full_address = "#{sy_club.address.city_name}, #{sy_club.address.state_name}, #{sy_club.address.country_name}"
	    			result = Geocoder.search(full_address).try(:first)
	    			unless result.present?
	    				puts "\nSleeping for 10 seconds.\n"
	    				sleep 10
	    				result = Geocoder.search(full_address).try(:first)
	    			end
	    			unless result.present?
	    				puts "Full Address: #{full_address} - sy_club_id: #{sy_club.id}"
	    			end
	    			result = [key, result.latitude, result.longitude]
	    			caputred.push(result)
	    		end

	    		if result.present?
	    			puts "Result: #{result} - sy_club_id: #{sy_club.id}"
	    			sy_club.address.update_columns(lat: result[1], lng: result[2])
	  			else
	  				errors.push({sy_club_id: sy_club.id, message: 'Some error while fetching address.'})
	  			end
				end
    	else
    		errors.push({sy_club_id: sy_club.id, message: 'Address not found.'})
    	end
    end
    binding.pry if Rails.env == 'development'
    puts "************************\nErrors"
    puts errors

    puts "************************\n\nCaptured"
    puts caputred.collect{|c| c.join(',')}
  end
end
