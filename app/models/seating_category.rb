class SeatingCategory < ApplicationRecord
  validates :category_name, presence: true, length: { maximum: 255 },
    uniqueness: { case_sensitive: false }

  has_many :event_seating_category_associations

  before_save :assign_category_colour

  scope :seating_category_name, ->(seating_category_name) { where("category_name ILIKE ?", "%#{seating_category_name}%") }
  scope :with_out_zero_payment_category, ->{where.not(category_name: ZERO_PAYMENT)}

  def rgba
    raise "#{self.try(:category_name)} category colour not found." unless self.category_colour.present?
    rgb = {}
    %w(r g b).inject(self.category_colour.to_i(16)) {|a,i| rest, rgb[i] = a.divmod 256; rest}
    "rgba(#{rgb['r']}, #{rgb['g']}, #{rgb['b']}, #{0.5})"
  end

  private
  def assign_category_colour
    return true if self.category_colour.present?
    begin
      @colour = '%06x' % (rand * 0xffffff)
    end while self.class.find_by(category_colour: @colour).present?
    self.category_colour = @colour
    return errors.empty?
  end

end
