RSpec.describe V2::SadhakProfilesController, :type => :controller do

  before :each do
    db_country = DbCountry.count > 0 ? DbCountry.first : FactoryBot.create(:db_country)
    @user = User.count > 0 ? User.first : FactoryBot.create(:user, country_id: db_country.id)
    @sadhak_profile = SadhakProfile.count > 0 ? SadhakProfile.first : SadhakProfile.create(email: @user.email, first_name: 'test', last_name: 'user', date_of_birth: Date.today - 1.year, gender: 'male', user_id: @user.id)
    sign_in @user
  end

  let(:valid_session) { {} }

  context 'family profile' do
    it 'should display the family profile' do
      @sadhak_profiles = @user.sadhak_profiles
      expect(@sadhak_profiles << @sadhak_profile).to exist
    end
  end
end
