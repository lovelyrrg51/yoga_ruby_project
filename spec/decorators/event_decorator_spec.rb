RSpec.describe EventDecorator do
  before do
    db_country = DbCountry.count > 0 ? DbCountry.first : FactoryBot.create(:db_country)
    db_state = FactoryBot.create(:db_state, country_id: db_country.id)
    db_city = FactoryBot.create(:db_city, country_id: db_country.id, state_id: db_state.id)
    user = FactoryBot.create(:user, country_id: db_country.id)
    cannonical_event = FactoryBot.create(:cannonical_event)
    address = FactoryBot.build(:address, city_id: db_city.id, country_id: db_country.id, state_id: db_state.id)
    @event = FactoryBot.build(:event, cannonical_event_id: cannonical_event.id,address: address).decorate
  end

  context 'When event start_date is present' do
    it 'Returns the event start date in 06 Feb format' do
      @event.event_start_date = DateTime.now
      expect(@event.start_date).to eq(DateTime.now.strftime('%d %b'))
    end
  end

  context 'When event start_date is not present' do
    it 'Returns empty string' do
      @event.event_start_date = ''
      expect(@event.start_date).to eq('')
    end
  end

  context 'When event description is present' do
    it 'Returns description with city name' do
      expect(@event.event_description).to eq("#{@event.description} - #{@event.address.db_city.name}")
    end
  end

  context 'When event description is blank' do
    it 'Returns city name' do
      @event.description = ''
      expect(@event.event_description).to eq(@event.address.db_city.name)
    end
  end
end
