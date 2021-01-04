class BhandaraDetail < ApplicationRecord
  validates :budget, :event_id, presence: true
  validates :budget, numericality: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }

  belongs_to :event
  has_many :bhandara_items

  after_save :update_bhandara_items

  def update_bhandara_items
    if self.event.event_end_date.present? and self.event.event_start_date.present?
      total_days = (self.event.event_end_date.to_date - self.event.event_start_date.to_date).to_i + 1
      total_items = self.bhandara_items.count
      #check if bhandara items are already there,
      #in case of update
      if total_days < total_items
        # remove bhandara items for extra days
        self.bhandara_items.where("day > ?", total_days).destroy_all
      else
        day_num = total_items + 1
        #create bhandara items for the number of days
        (day_num..total_days).each do |day|
          self.bhandara_items.create day: day
        end
      end
    end
  end
end
