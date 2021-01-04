module Api::V1
  class SyClubDigitalArrangementDetailSerializer < ActiveModel::Serializer
    attributes :id, :lcd_size, :lcd_size, :lcd_model, :speakers_count, :speaker_model, :dvd_player_model, :generator_company, :inverter_company, :is_laptop_available, :internet_provider, :internet_speed, :internet_data_plan
    
    #embed :ids
    has_one :sy_club
  end
end
