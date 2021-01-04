require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { Class.new }

  it { is_expected.to act_as_paranoid }

  describe "associations" do

    context '#has_many' do
      it { should have_many(:authentication_tokens)}
      it { should have_many(:orders).dependent(:destroy)}
      it { should have_many(:relations).dependent(:destroy)}
      it { should have_many(:purchased_digital_assets)}
      it { should have_many(:digital_assets).through(:purchased_digital_assets)}
      it { should have_many(:purchased_digital_assets)}
      it { should have_many(:sadhak_profiles).conditions(relations: { is_verified: true }).through(:relations)}
      it { should have_many(:events).with_foreign_key(:creator_user_id)}
      it { should have_many(:event_orders)}
      it { should have_many(:user_roles).dependent(:destroy)}
      it { should have_many(:roles).through(:user_roles)}
      it { should have_many(:role_dependencies).through(:user_roles)}
      it { should have_many(:user_group_mappings)}
      it { should have_many(:user_groups).through(:user_group_mappings)}

      it { should have_many(:user_ticket_group_associations)}

      it { should have_many(:ticket_groups).through(:user_ticket_group_associations)}
      it { should have_many(:group_tickets).through(:ticket_groups).source(:tickets)}

      it { should have_many(:created_events).class_name('Event').with_foreign_key(:creator_user_id)}
      it { should have_many(:tickets).class_name('Ticket').with_foreign_key(:user_id)}
      it { should have_many(:assigned_tickets).class_name('Ticket').with_foreign_key(:assigned_user_id)}
      it { should have_many(:registration_center_users).dependent(:destroy)}
      it { should have_many(:registration_centers).through(:registration_center_users)}
      it { should have_many(:registered_events).through(:registration_centers).source(:events) }

      it { should have_many(:valid_registered_center_events).conditions("registration_centers.start_date >= #{Date.today} AND registration_centers.end_date <= #{Date.today}").through(:registration_centers).source(:events)}
      it {should have_many(:rc_events).conditions("registration_centers.start_date <= #{Date.today} AND registration_centers.end_date >= #{Date.today}")}

      it { should have_many(:delayed_job_progresses).dependent(:destroy)}

    end

    context '#has_one' do
      it { should have_one(:sadhak_profile).dependent(:destroy).autosave(false)}
      it { should have_one(:address).through(:sadhak_profile)}
    end

    context '#belongs_to' do
      it do
        should belong_to(:db_country).class_name('DbCountry')
          .with_foreign_key(:country_id)
          .optional
      end
    end

  end

  describe "delegate" do
    it { should delegate_method(:full_name_with_syid).to(:sadhak_profile).with_prefix('sadhak').allow_nil }
    it { should delegate_method(:window_events).to(:sadhak_profile).with_prefix('sadhak').allow_nil }
    it { should delegate_method(:active_club).to(:sadhak_profile).allow_nil}
  end

  describe "set constants" do
    before { stub_const("#{described_class}", user) }
    it { expect(described_class::USER_ROLES).to eq(%w(photo_approval_admin super_admin event_admin digital_store_admin group_admin club_admin india_admin)) }
  end

end
