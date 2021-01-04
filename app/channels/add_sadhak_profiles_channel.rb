class AddSadhakProfilesChannel < ApplicationCable::Channel

  def subscribed
    stream_from 'add_sadhak_profiles'
  end

end  