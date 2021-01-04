FactoryBot.define do
  factory(:sy_club_validity_window) do
    club_reg_end_date "2015-12-31"
    club_reg_start_date "2015-07-01"
    membership_end_date "2015-10-31"
    membership_start_date "2015-08-01"
    sy_club_id nil
    sy_club_sadhak_profile_association_id nil
  end
end
