namespace :user do
  desc "TODO"
  task test: :environment do
    ret = UsersController.new.test
    puts ret
  end

  task depricate_users: :environment do
    unique_but_not_added = []
    useless = []
    sp_with_no_user = []
    duplicate = []
    depricated_users = []
    all_users = User.where.not(username: ["", nil, "NULL"]).pluck(:id, :username)
    # Find duplicate users
    SadhakProfile.includes(:user).find_in_batches(start: 1, batch_size: 5000) do |group|
      group.each do |sp|
        users = all_users.select{|user| user[1] == sp.username}
        user_ids = []
        if sp.user.present?
          user_ids = users.collect{|u| u[0]} if users.count > 0
          if users.count > 1 and user_ids.include?(sp.user.id)
            user_ids.delete(sp.user.id)
            duplicate.push({id: sp.id, users: user_ids})
          elsif users.count == 1 and user_ids.last != sp.user_id
            unique_but_not_added.push({id: sp.id, users: user_ids})
          elsif users.count == 1
            useless.push(user_ids.last)
          end
        else
          sp_with_no_user.push(sp.id)
        end
        print "#{sp.id}-"
      end
    end

    # Write in a file to maintain record
    begin
      # file = File.open("./depricated_user.txt", "w")
      all_user_ids = SadhakProfile.where.not(user_id: [nil, "NULL", ""]).pluck(:user_id)
      duplicate.each do |d|
        to_be_depricated_user = d[:users] - all_user_ids
        depricated_users += to_be_depricated_user
      end
      depricated_users = depricated_users.uniq
      puts depricated_users.count
      # file.write(depricated_users.to_sentence(words_connector:',', two_words_connector: ',', last_word_connector: ','))
    rescue Exception => e
      #some error occur, dir not writable etc.
    ensure
      # file.close unless file.nil?
    end

    # Depricate user
    user_depricated = []
    begin
      ActiveRecord::Base.transaction do
        User.where(id: depricated_users).each_with_index do |u, _index|
          next if SadhakProfile.where(user_id: u.id).count > 0
          is_success = u.update(username: "#{u.username}_#{u.id}_deprecated")
          if is_success
            user_depricated.push(is_success)
            print "#{u.id}_#{u.username}-"
          else
            puts "Error at #{_index}_#{u.id}"
            break
          end
        end
      end
      puts "To be Depricated count : #{depricated_users.count}"
      puts "User Depricated : #{user_depricated.count}"
      rescue ActiveRecord::ActiveRecordError => e
        logger.info(e)
        puts "Error in Transaction."
      rescue Exception => e
        logger.info(e)
        puts "Some other error."
    end
  end
end
