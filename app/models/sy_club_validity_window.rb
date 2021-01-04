class SyClubValidityWindow < ApplicationRecord
  include CommonHelper
  belongs_to :sy_club
  has_many :sy_club_sadhak_profile_associations
  has_many :sadhak_profiles, through: :sy_club_sadhak_profile_associations

  # Job that will mark members as expires if membership over
  def mark_forum_members_as_expired
    windows =  SyClubValidityWindow.includes(:sy_club_sadhak_profile_associations).where('membership_end_date < ?', Date.current)
    clubs = SyClub.all.collect{|c| {id: c.id, name: c.name}}
    windows.count > 0 and windows.each do |validity_win|
      to_be_expired_sadhaks = validity_win.sy_club_sadhak_profile_associations.where(status: SyClubSadhakProfileAssociation.statuses['approve'])
      if to_be_expired_sadhaks.count > 0
        association_ids = to_be_expired_sadhaks.ids
        sadhak_ids = to_be_expired_sadhaks.pluck(:sadhak_profile_id)
        recipients = SadhakProfile.where(id: sadhak_ids).map {|e| {id: e.id, email: e.email}}
        SyClubSadhakProfileAssociation.where(id: association_ids).each do |expired_sadhak|
          expired_sadhak.update_attribute('status', SyClubSadhakProfileAssociation.statuses['expired'])
          club = clubs.find{|c| c[:id] == expired_sadhak.sy_club_id}
          recipient = recipients.find{|r| r[:id] == expired_sadhak.sadhak_profile_id}
          email = recipient.present? ? recipient[:email] : ''
          from = GetSenderEmail.call(club)
          ApplicationMailer.send_email(from: from, recipients: [email], template: 'forum_membership_expired', subject: "#{club[:name].titleize} - Membership Expired", club: club, validity_window: validity_win).deliver if club.present? and email.is_valid_email?
        end
      end
    end
  end
end
