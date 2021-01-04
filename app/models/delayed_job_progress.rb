class DelayedJobProgress < ApplicationRecord
  include AASM
  acts_as_paranoid

  belongs_to :user
  belongs_to :delayed_job_progressable, polymorphic: true

  serialize :result, JSON

  before_create :assign_user

  enum status: [ :initiated , :processing, :completed, :failed, :error ]

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :processing
    state :completed
    state :failed
  end

  def percentage
    '%.2f' % (progress_max.zero? ? 0 : progress_current / progress_max * 100).to_f
  end

  private

  def assign_user
    self.user = $current_user
  end

end
