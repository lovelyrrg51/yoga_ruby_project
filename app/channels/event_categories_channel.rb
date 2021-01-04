class EventCategoriesChannel < ApplicationCable::Channel

  def subscribed
    stream_from 'seats_available'
  end

end  