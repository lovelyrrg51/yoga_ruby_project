class EventDecorator < Draper::Decorator
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def start_date
    event_start_date.present? ? event_start_date.strftime('%d %b') : ''
  end

  def event_description
    if description.present?
      "#{description} - #{address.db_city.name}"
    else
      address.db_city.name
    end
  end

  def event_duration
    "#{event_start_date&.strftime('%B %d, %Y')} to #{event_end_date&.strftime('%B %d, %Y')}"
  end
end
