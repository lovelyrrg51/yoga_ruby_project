class AspectsOfLife < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = [:aspect_feedbacks]
  validates :sadhak_profile_id, uniqueness: true
  belongs_to :sadhak_profile
  has_many :aspect_feedbacks, dependent: :destroy

  accepts_nested_attributes_for :aspect_feedbacks, allow_destroy: true
  after_save :create_aspect_feedback

  def create_aspect_feedback

    AspectFeedback.aspect_types.each do |at|
      if self.aspect_feedbacks.find_by(aspect_type: at).nil?
        self.aspect_feedbacks.create(
          aspect_type: at[1],
          rating_before: 0,
          rating_after: 0
        )
      end
    end
  end
end
