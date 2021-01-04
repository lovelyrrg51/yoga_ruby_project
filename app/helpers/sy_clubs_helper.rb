module SyClubsHelper
    def sy_club_member_status_color(sy_club_member)
        (sy_club_member && (sy_club_member.approve? || sy_club_member.renewed?) ) ? "success-color" : "primary-color"
    end
end
