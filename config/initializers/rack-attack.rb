class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip # unless req.path.start_with?('/assets')
  end
  # Allows 20 requests in 8  seconds
  #        40 requests in 64 seconds
  #        ...
  #        100 requests in 0.38 days (~250 requests/day)
  # (1..5).each do |level|
  #   throttle("req/ip/#{level}", :limit => (20 * level), :period => (8 ** level).seconds) do |req|
  #     req.ip
  #   end
  # end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  # throttle('logins/ip', :limit => 5, :period => 20.seconds) do |req|
  #   if req.path == '/users/sign_in' && req.post?
  #     req.ip
  #   end
  # end

  throttle('/forgot_syid/search_by_mobile', :limit => 10, :period => 5.minutes) do |req|
    if req.path == '/forgot_syid/search_by_mobile' && req.post?
      req.ip
    end
  end

  throttle('/forgot_syid/search_by_email', :limit => 10, :period => 5.minutes) do |req|
    if req.path == '/forgot_syid/search_by_email' && req.post?
      req.ip
    end
  end

  throttle('/forgot_syid/search_by_details', :limit => 10, :period => 5.minutes) do |req|
    if req.path == '/forgot_syid/search_by_details' && req.post?
      req.ip
    end
  end

  # /sadhak_profiles/16116904-0352-4d99-8114-5e8b9e30af45-96973d/verify_sadhak_profile/send_email_verification
  throttle('send_email_verification', limit: 2, period: 5.minutes) do |req|
    if req.path =~ /\/sadhak_profiles\/[a-zA-Z0-9-]+\/verify_sadhak_profile\/send_email_verification/i && req.patch?
      req.ip
    end
  end

  throttle('send_mobile_verification', limit: 2, period: 5.minutes) do |req|
    if req.path =~ /\/sadhak_profiles\/[a-zA-Z0-9-]+\/verify_sadhak_profile\/send_mobile_verification/i && req.patch?
      req.ip
    end
  end

  throttle('resend_email_verification', limit: 2, period: 5.minutes) do |req|
    if req.path =~ /\/sadhak_profiles\/[a-zA-Z0-9-]+\/verify_sadhak_profile\/resend/i && req.patch?
      req.ip
    end
  end

  # throttle('resend_mobile_verification', limit: 2, period: 5.minutes) do |req|
  #   if req.path =~ /\/sadhak_profiles\/[a-zA-Z0-9-]+\/verify_sadhak_profile\/resend/i && req.patch?
  #     req.ip
  #   end
  # end

  # Allows 20 requests in 8  seconds
  #        40 requests in 64 seconds
  #        ...
  #        100 requests in 0.38 days (~250 requests/day)
  (1..5).each do |level|
    throttle("logins/ip/#{level}", :limit => (20 * level), :period => (8 ** level).seconds) do |req|
      if req.path == '/users/sign_in' && req.post?
        req.ip
      end
    end
  end

  # Throttle POST requests to /login by username param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/username:#{req.username}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  # throttle("logins/username", :limit => 5, :period => 20.seconds) do |req|
  #   if req.path == '/users/sign_in' && req.post?
  #     # return the username if present, nil otherwise
  #     req.params.fetch('user', {})['username'].presence
  #   end
  # end
  # Allows 20 requests in 8  seconds
  #        40 requests in 64 seconds
  #        ...
  #        100 requests in 0.38 days (~250 requests/day)
  (1..5).each do |level|
    throttle("logins/username/#{level}", :limit => (20 * level), :period => (8 ** level).seconds) do |req|
      if req.path == '/users/sign_in' && req.post?
        # return the username if present, nil otherwise
        req.params.fetch('user', {})['username'].presence
      end
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  self.throttled_response = lambda do |env|
    [ 503,  # status
      {},   # headers
      ['']  # body
    ]
  end

  # Always allow requests from localhost
  # (blocklist & throttles are skipped)
  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

end
