namespace :event_522_applicants_removal do
  desc "Removing some applicants from Event 522"
  task :remove_applicants, [:filename,:event_id] => :environment do |t, args|
  	errors = []
  	syids = []
    File.open("#{args[:filename]}", "r").each_with_index do |line, index|
        s_no, event_reg_status, shivit_attented_status, syid, name,gender, mobile, dob, email, state, country =  line.strip.split(",")
        syids.push(syid.delete('SY').to_i)
         @event_id = "#{args[:event_id]}"
    end
    @registrations = EventRegistration.where(sadhak_profile_id: syids, event_id: @event_id)
    event_order_ids = @registrations.pluck(:event_order_id)
    event_orders = EventOrder.where(id: event_order_ids)
    eo_res = event_orders.update_all(is_deleted: true)
    # @registrations.destroy_all
    res = @registrations.update_all(is_deleted: true)
    if res and eo_res
      puts "regsitration updated"
    else
      puts "error in update"
    end
    # puts "helloooo event registration"
    # puts @registrations.ids
    # puts "registrations count"
    # puts @registrations.count
    # puts "hello syids"
    # puts syids
    puts "Event_oRder Ids"
    puts event_order_ids
    puts "EvenT OrDEr cOUnT"
    puts event_order_ids.count
  end
end