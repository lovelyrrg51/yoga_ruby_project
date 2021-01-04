class SyClubMemberTransfer < ApplicationRecord
  include AASM

  default_scope { where(is_deleted: false) }

  scope :sadhak_profile_id, lambda { |sadhak_profile_id| where(sadhak_profile_id: sadhak_profile_id) }
  scope :from_club_id, lambda { |from_club_id| where(from_club_id: from_club_id) }
  scope :to_club_id, lambda { |to_club_id| where(to_club_id: to_club_id) }
  scope :status, lambda { |status| where(status: status) }
  scope :requester_id, lambda { |requester_id| where(requester_id: requester_id) }
  scope :responder_id, lambda { |responder_id| where(responder_id: responder_id) }
  scope :sy_club_id, lambda { |sy_club_id| where("to_club_id = ? OR from_club_id = ?", sy_club_id, sy_club_id) }

  validates :sy_club_member_id, presence: true
  validates :sadhak_profile_id, presence: true
  validates :from_club_id, presence: true
  validates :to_club_id, presence: true
  validates :requester_id, presence: true

  belongs_to :sadhak_profile
  belongs_to :requester_user, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :responder_user, class_name: 'User', foreign_key: 'responder_id'
  belongs_to :transfer_out_club, class_name: 'SyClub', foreign_key: 'from_club_id'
  belongs_to :transfer_in_club, class_name: 'SyClub', foreign_key: 'to_club_id'
  belongs_to :sy_club_member

  before_create :is_transfer_in_out_club_enabled?, :is_request_for_transfer_profile_board_member?, :is_duplicate_request?, :check_sadhak_already_joined_to_club?, :cancel_pending_requests_if_from_same_club, :is_request_pending_to_same_club_from_another_club?
  after_create :update_sy_club_member, :notify_member, :notify_admins
  enum transfer_reason: {forum_near: 0, forum_timing: 1, relocation: 2, others: 4}

  enum status: {requested: 0, approved: 1, refer_backed: 2, cancelled: 3}

  aasm column: :status, enum: true, whiny_transitions: false do
    state :requested, initial: true
    state :approved
    state :refer_backed
    state :cancelled

    event :approve, before: :has_valid_state?, guards: [:is_transfer_in_out_club_enabled?, :is_request_for_transfer_profile_board_member?, :check_sadhak_already_joined_to_club?, :is_membership_transferred?], after_commit: [:remove_pendings, :notify_member] do
      transitions from: :requested, to: :approved
    end

    event :refer_back, before: :has_valid_state?, after_commit: :after_disapproved do
      transitions from: :requested, to: :refer_backed
    end

    event :cancel, before: :has_valid_state?, after_commit: :after_disapproved do
      transitions from: :requested, to: :cancelled
    end
  end

  def self.preloaded_data
    SyClubMemberTransfer.order(:id).includes(:sadhak_profile, :requester_user, :responder_user, { transfer_out_club: [ sy_club_sadhak_profile_associations: [:sadhak_profile] ] }, { transfer_in_club: [ sy_club_sadhak_profile_associations: [:sadhak_profile] ] }, :sy_club_member)
  end

  def self.transfer_approved_request(days = nil)
    days ||= 7
    begin
      approved_requests = SyClubMemberTransfer.preloaded_data.approved.where("created_at >= ?", Date.today - days.to_i)
      if approved_requests.count > 0
        data_approve = generate_report(approved_requests)
        blob_approve = GenerateExcel.generate(data_approve)
      end
    rescue SyException => e
      is_error = true
      message = e.message
      logger.info("Manual Exception: #{message}")
    rescue Exception => e
      is_error = true
      message = e.message
      logger.info("Runtime Exception: #{message}")
    end
    unless is_error
      return blob_approve
    end
  end

  def self.transfer_pending_request(days = nil)
    days ||= 7
    begin
      pending_requests = SyClubMemberTransfer.preloaded_data.requested.where("created_at >= ?", Date.today - days.to_i)
      if pending_requests.count > 0
        data_pending = generate_report(pending_requests)

        blob_pending = GenerateExcel.generate(data_pending)
      end
    rescue SyException => e
      is_error = true
      message = e.message
      logger.info("Manual Exception: #{message}")
    rescue => e
      is_error = true
      message = e.message
      logger.info("Runtime Exception: #{message}")
    end

    blob_pending unless is_error
  end

  def self.generate_report(requests)
    # header for weekly forum transfer report
    header = ["SYID", "FIRST_NAME", "LAST_NAME", "SOURCE_CLUB_ID", "SOURCE_CLUB_NAME", "TARGET_CLUB_ID", "TARGET_CLUB_NAME", "TRANSFER_REASON", "REQUESTER_USER", "RESPONDER_USER" , "REQUEST_STATUS", "REQUESTED_AT"]
    rows = []
    requests.each_with_index do |request, index|

      # Hold single row
      row = []
      sadhak_profile = request.sadhak_profile
      from_club = SyClub.find_by(id: request.from_club_id) if request.from_club_id.present?
      to_club = SyClub.find_by(id: request.to_club_id) if request.to_club_id.present?
      req_user = User.find_by(id: request.requester_id)
      res_user = User.find_by(id: request.responder_id)
      # push data
      row.push(sadhak_profile.try(:syid))

      row.push(sadhak_profile.try(:first_name))

      row.push(sadhak_profile.try(:last_name))

      row.push(request.try(:from_club_id))

      row.push(from_club.try(:name))

      row.push(request.try(:to_club_id))

      row.push(to_club.try(:name))

      if request.transfer_reason != 'others'
        row.push(request.transfer_reason)
      else
        row.push(request.other_transfer_reason)
      end

      row.push(req_user.try(:sadhak_profile).try(:syid))

      if  request.status.present? and request.status == 'approved' and res_user.try(:sadhak_profile).try(:syid).nil?
        row.push('Auto approve in 14 days')
      else
        row.push(res_user.try(:sadhak_profile).try(:syid))
      end

      row.push(request.try(:status))

      row.push(request.created_at.to_s)

      # Push single row to array
      rows.push(row)

    end
    {
      header: header,
      rows: rows
    }
  end

  private

  # Model Callbacks definitions
  def is_transfer_in_out_club_enabled?
    errors.add(:requested, "forum '#{self.transfer_in_club.name}' is in disable state. Please contact to board members.") if self.transfer_in_club.status != "enabled"
    errors.add(:current, "forum '#{self.transfer_out_club.name}' is in disabled state. Please contact to board members.") if (self.transfer_out_club.status != "enabled" and false)
    errors.empty?
  end

  # Check that request for transfer profile is in transfer_out_club board members list.
  def is_request_for_transfer_profile_board_member?
    errors.add(:profile, "Name: #{self.sadhak_profile.full_name.titleize} SYID: #{self.sadhak_profile_id} is board member of #{self.transfer_out_club.name.titleize} forum.") if self.transfer_out_club.is_board_member?(self.sadhak_profile_id)
    errors.empty?
  end

  # Check for duplicate request
  def is_duplicate_request?
    errors.add(:duplicate, "transfer request.") if self.class.where(sadhak_profile_id: self.sadhak_profile_id, from_club_id: self.from_club_id, to_club_id: self.to_club_id, status: self.class.statuses['requested']).count > 0
    errors.empty?
  end

  # Check wether sadhak is already joined to transferred club (transfer_in_club)
  def check_sadhak_already_joined_to_club?
    errors.add(:sadhak, "is already member of #{self.transfer_in_club.name.titleize} forum.") if SyClubMember.where(sy_club_id: self.to_club_id, sadhak_profile_id: self.sadhak_profile_id, status: SyClubMember.statuses['approve']).count > 0
    errors.empty?
  end

  # Cancel pending requests if user is making another request from same club to another club.
  def cancel_pending_requests_if_from_same_club
    self.class.preloaded_data.where(sadhak_profile_id: self.sadhak_profile_id, from_club_id: self.from_club_id, status: self.class.statuses['requested']).each do |sy_club_member_transfer|
      sy_club_member_transfer.responder_user = self.requester_user
      unless sy_club_member_transfer.cancel!
        errors.add(:there, "is some error while canceling the previous request ##{sy_club_member_transfer.id}. Please contact to board members.")
      end
    end
    errors.empty?
  end

  # If somebody create request to club A from (B as well as C)??
  def is_request_pending_to_same_club_from_another_club?
    self.class.preloaded_data.where(sadhak_profile_id: self.sadhak_profile_id, to_club_id: self.to_club_id, status: self.class.statuses['requested']).each do |req|
      errors.add(:sadhak, "Name: #{req.requester_user.name} has already created a request for transfer from #{req.transfer_out_club.name.titleize} forum to #{req.transfer_in_club.name.titleize} froum.")
    end
    errors.empty?
  end

  # After create update sy_club_member_details
  def update_sy_club_member
    unless self.sy_club_member.update(transferred_to_club_id: self.to_club_id)
      errors.add(:there, "is some error while processing your transfer request. Please try again.")
      logger.info("sy_club_member: #{sy_club_member.as_json}")
      logger.info("sy_club_member_transfer: #{self.as_json}")
    end
    errors.empty?
  end

  # AASM Callbacks definitions
  def remove_pendings
    begin
      if self.sy_club_member.remove_pendings_transfer(self.to_club_id, self.sadhak_profile_id, "Transfer in request accepted from #{self.transfer_in_club.name.titleize}-#{self.to_club_id}.")
      else
        logger.info("There is some error in removing pending enteries from sy_club_member table for #{self.as_json}.")
      end
    rescue Exception => e
      logger.info("Exception in remove_pendings callback AASM : SyClubMemberTransferModel")
      logger.info(e.backtrace)
    end
    true
  end

  def is_membership_transferred?
    sy_club_member = self.sy_club_member
    ApplicationRecord.transaction do
      if sy_club_member.transfer!
        transferred_member = SyClubMember.new(sy_club_id: sy_club_member.transferred_to_club_id, status: sy_club_member.class.statuses['approve'], sadhak_profile_id: sy_club_member.sadhak_profile_id, sy_club_validity_window_id: sy_club_member.sy_club_validity_window_id, club_joining_date: sy_club_member.club_joining_date)
        unless transferred_member.save
          errors.add(:member, "has already joined to this club.")
        end
      else
        errors.add(:unable, "to change existing member status.")
      end
    end
    errors.empty?
  end

  def has_valid_state?
    errors.add(:invalid, "aasm transition.") unless self.requested?
    errors.empty?
  end

  def after_disapproved
    logger.info("after_disapproved called.")
    begin
      self.sy_club_member.update(transferred_to_club_id: nil)
      notify_member
    rescue Exception => e
      logger.info("Exception in after_disapproved callback AASM : SyClubMemberTransferModel")
      logger.info("Error in changing state from #{aasm.from_state} to #{aasm.to_state} by (event: #{aasm.current_event})")
      logger.info(e.backtrace)
    end
    true
  end

  def notify_member
    begin
      subject = "Forum membership transfer request status: #{self.status.titleize}."
      recipient = self.sadhak_profile.email.present? ? self.sadhak_profile.email : ""
      ashram_emails = self.status == 'refer_backed' ? ["shivyogportal@gmail.com"] : []
      UserMailer.send_email(recipients: recipient, bcc: ashram_emails, subject: subject, template: 'forum_membership_transfer_user', sy_club_member_transfer: self).deliver if recipient.is_valid_email?
    rescue Exception => e
      logger.info("Exception in notify_member method : SyClubMemberTransferModel")
      logger.info(e.message)
      logger.info(e.backtrace)
    end
    true
  end

  def notify_admins
    ["transfer_in_club", "transfer_out_club"].each_with_index do |notify_type, index|
      begin
        type_string = notify_type.include?('in') ? "transfer in" : "transfer out"
        subject = "Forum membership #{type_string} request."
        recipients = self.send(notify_type.to_sym).board_member_emails
        UserMailer.send_email(recipients: recipients, subject: subject, template: 'forum_membership_transfer_admin', sy_club_member_transfer: self, index: index).deliver if recipients.count > 0
      rescue Exception => e
        logger.info("Exception in notify_admins method, notify_type: #{notify_type} : SyClubMemberTransferModel")
        logger.info(e.message)
        logger.info(e.backtrace)
      end
    end
    true
  end

  def log_status_change
    status_notes = "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
    logger.info(status_notes)
  end

end
