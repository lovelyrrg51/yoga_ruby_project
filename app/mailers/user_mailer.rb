class UserMailer < ApplicationMailer
  include CommonHelper

  def order_confirmation(user, order)
    @user = user
    @order = order
    mail(to: @user.email, subject: 'Payment has been received')
  end

  def ticket_create_admin_email(recipient, ticket)
    @user = recipient
    @ticket = ticket
    mail(to: recipient.email, subject: 'New ticket alert #' + @ticket.id.to_s())
  end

  def sadhak_email_confirmation_notice(sadhak_profile)
    @sadhak_profile = sadhak_profile
    mail(to: @sadhak_profile.email, subject: 'Confirm your email')
  end

  def ticket_response_submitted_notification(ticket_response)
    @ticket_response = ticket_response
    @ticket = ticket_response.ticket
    @user = ticket_response.user
    mail(to: @user.email, subject: "Ticket response submitted successfully for ticket #" + @ticket.id.to_s)
  end

  def sadhak_profile_ownership_request(sadhak_profile)
    @sadhak_profile = sadhak_profile
    mail(to: @sadhak_profile.email, subject: 'Sadhak Profile confirmation token')
  end

  def sadhak_profile_association_verification(sadhak_profile, relation)
    @sadhak_profile = sadhak_profile
    @relation = relation
    mail(to: @sadhak_profile.email, subject: 'Verify your email')
  end

  def welcome(email, user, sadhak_profile)
    @email = email
    @user = user
    @sadhak_profile = sadhak_profile
    mail(to: @email, subject: 'Shivyog regsitration')
  end

  def user_email_confirmation_notice(email, verification_token, sadhak_profile)
    @email = email
    @code = verification_token
    @name = sadhak_profile.try(:full_name) || sadhak_profile.try(:user).try(:name)
    @from = GetSenderEmail.call(sadhak_profile)
    mail(from: @from, to: @email, subject: 'Shivyog verification code')
  end

  def resend_transaction_receipt_email(email, txns, event_order)
    @txns = txns
    @email= email
    @event_order = event_order
    @total_transactions_amount = txns.collect {|t| t[:amount]}.sum.to_f
    mail(to: @email, subject: 'Payment has been received')
  end

  def resend_registration_number(email, registration_number, event_name)
    @email = email
    @registration_number = registration_number
    @event_name = event_name
    mail(to: @email, subject: 'Shivyog updated registration number')
  end

  def notify_sadhaks(sadhak_profiles, sadhak_message, sy_club_id)
    @sadhak_profiles = sadhak_profiles
    from = 'support@absclp.com'
    if sadhak_profiles.size == 1
     from = GetSenderEmail.call(sadhak_profiles.last)
    end
    @message = sadhak_message
    if sy_club_id.present?
      @sy_club = SyClub.find(sy_club_id)
      from = GetSenderEmail.call(@sy_club)
    end
    @sadhak_profiles_emails = @sadhak_profiles.map {|e|[e.email]}
    if @sadhak_profiles_emails.count > 0
      mail(from: from, to: @sadhak_profiles_emails, subject: 'Shivyog Notifications')
    end
  end

  def notify_sadhak(sadhak_profile, sadhak_message)
    @sadhak_profile = sadhak_profile
    from = GetSenderEmail.call(sadhak_profile)
    @message = sadhak_message
    mail(from: from, to: @sadhak_profile.email, subject: 'Shivyog Notifications')
  end

  def reset_password_notification(options = {})
  	@options = options
  	@sadhak_profile = options[:sadhak_profile]
  	from  = GetSenderEmail.call(@sadhak_profile)
    mail(from: from, to: @sadhak_profile.email, subject: 'Reset password notification')
  end

  def paypal_payment_success(event_order, paypal_payment)
    @paypal = paypal_payment
    @event_order = event_order
    mail(to: @event_order.guest_email, subject: 'Payment has been received')
  end

  def send_syid_list(email, token, profiles)
    @email = email
    @token = token
    @profiles = profiles
    mail(to: @email, subject: "Shivyog SYID's list registered with #{email}")
  end

  def activity_approval_confirmation(emails, club_event_association)
    @emails = emails
    @club_event_association = club_event_association
    mail(to: @emails, subject: "Activity Approval Confirmation")
  end

  def forum_creation_notify_board_members(forum, is_created, updated_details)
    updated_details ||= {}
    @forum = forum
    @is_created = is_created
    @board_members = @forum.sy_club_sadhak_profile_associations.where(sy_club_user_role_id: [1,2])
    @is_board_member_updated = updated_details[:is_board_member_updated].present?
    @is_address_updated = updated_details[:is_address_updated].present?
    subject = if @is_created
      'Congratulations! New Forum created'
    else
      if @is_board_member_updated
        "Congratulations! Forum's Board Members Updated"
      elsif @is_address_updated
        "Congratulations! Forum's Venue Address Updated"
      else
        "Congratulations! Forum Updated"
      end
    end
    mail(to: @forum.board_member_emails, subject: subject)
  end
end
