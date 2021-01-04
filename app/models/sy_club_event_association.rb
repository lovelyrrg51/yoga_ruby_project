class SyClubEventAssociation < ApplicationRecord
  belongs_to :event
  belongs_to :sy_club
end
