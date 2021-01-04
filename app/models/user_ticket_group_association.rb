class UserTicketGroupAssociation < ApplicationRecord
  belongs_to :ticket_group
  belongs_to :user
end
