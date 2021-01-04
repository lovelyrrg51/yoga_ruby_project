class User < ApplicationRecord
  acts_as_paranoid

  has_many :authentication_tokens

  USER_ROLES = %w(photo_approval_admin super_admin event_admin digital_store_admin group_admin club_admin india_admin)
  # validates :email, presence: true, length: { maximum: 255 }
  # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  # validates :encrypted_password, presence: true, length: { maximum: 255 }
  # validates :name, presence: true, length: { maximum: 255 }
  # validates :date_of_birth, presence: true#, message: 'Date of birth not found'
  auto_strip_attributes :name, :last_name
  # validates_format_of  :email, :allow_blank => true
  # validates :username, uniqueness: true
  # validates :email, uniqueness: true, allow_blank: true
  # validates :contact_number, uniqueness: true
  # validates :username, format: { with: /\A[a-zA-Z0-9]+\Z/ }
  # validates_format_of :contact_number, :with =>  /\d[0-9]\)*\z/ , :message => "Only positive number without spaces are allowed"
  has_many :orders, dependent: :destroy
  has_many :purchased_digital_assets
  has_many :digital_assets, through: :purchased_digital_assets
  has_many :relations, dependent: :destroy
  has_one :sadhak_profile, autosave: false, dependent: :destroy
  has_one :address, through: :sadhak_profile

  has_many :sadhak_profiles, -> { where(relations: { is_verified: true }) },
    through: :relations, as: :related_profiles
  has_many :events, foreign_key: :creator_user_id

  #has_many :event_registrations  # might have to specify foreign key here
  #has_many :events, :through => :event_registrations, :as => :facilitated_registrations
  has_many :create_forum_requests
  has_many :event_orders
  has_many :event_orders, as: :rc_event_orders, foreign_key: :rc_user_id

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :role_dependencies, through: :user_roles
  has_many :user_group_mappings
  has_many :user_groups, through: :user_group_mappings

  has_many :event_orders
  has_many :user_ticket_group_associations
  has_many :ticket_groups, through: :user_ticket_group_associations
  #tickets from the groups that user belongs to
  has_many :group_tickets, through: :ticket_groups, source: :tickets
  has_many :created_events, foreign_key: :creator_user_id, class_name: 'Event'

  #tickets that are created by user
  has_many :tickets, foreign_key: :user_id, class_name: 'Ticket'
  #tickets that are assigned to user
  has_many :assigned_tickets, foreign_key: :assigned_user_id, class_name: "Ticket"

  has_many :registration_center_users, dependent: :destroy
  has_many :registration_centers, through: :registration_center_users
  has_many :registered_events, through: :registration_centers, source: :events
  has_many :valid_registered_center_events, lambda { where("registration_centers.start_date >= :current_date AND registration_centers.end_date <= :current_date", current_date: Date.today) }, through: :registration_centers, source: :events
  has_many :rc_events, lambda { where("registration_centers.start_date <= ? AND registration_centers.end_date >= ?", Date.today, Date.today) }, :through => :registration_centers, source: :events
  belongs_to :db_country, class_name: "DbCountry", foreign_key: "country_id", optional: true
  has_many :delayed_job_progresses, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  after_create :set_authentication_token

  delegate :full_name_with_syid, to: :sadhak_profile, prefix: "sadhak", allow_nil: true
  delegate :window_events, to: :sadhak_profile, prefix: "sadhak", allow_nil: true

  delegate :active_club, to: :sadhak_profile, allow_nil: true

  def set_authentication_token
    update_columns(authentication_token: SecureRandom.hex(13))
  end

  def create_empty_order(items_payment_pending = [])
    #assign_stat = Order::CART
    @order = self.orders.create(status: 0)
    logger.info "user model new order"
    logger.info @order
    if (items_payment_pending.count > 0)
      LineItem.where("id in (?)", items_payment_pending).update_all(:order_id => @order.id)
      @order.total_amount = LineItem.where("id in (?)", items_payment_pending).sum(:total_price)
    end
    @order
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      columns = %w(email name last_name)
      csv << columns
      all.each do |user|
        csv << user.attributes.values_at(*columns)
      end
    end
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def rc(event)
    registration_center = nil

    registration_center_users = RegistrationCenterUser.includes(:registration_center).where(registration_center_id: EventRegistrationCenterAssociation.where(event_id: event.try(:id) || event.to_s).pluck(:registration_center_id))

    registration_center_users.each do |rcu|
      is_rc_user = (rcu.user_id == self.id and rcu.registration_center.present? and rcu.registration_center.start_date.to_date <= Date.current and rcu.registration_center.end_date.to_date >= Date.current)

      if is_rc_user
        registration_center = rcu.registration_center

        break
      end
    end

    registration_center
  end

  def rc?(event)
    self.rc(event).present?
  end

  # Get all permissions associated with a user with or without constraints
  def permissions(*constraints)
    _permissions = {
      super_admin: self.super_admin?,
      digital_store_admin: self.digital_store_admin?,
      group_admin: self.group_admin?,
      event_admin: self.event_admin?,
      photo_approval_admin: self.photo_approval_admin?,
      club_admin: self.club_admin?,
      india_admin: self.india_admin?,
    }

    independent_roles = self.user_roles.joins(:role).where(roles: {role_type: Role.role_types.independent})

    independent_roles.each do |independent_role|
      _permissions[independent_role.role.name] ||= true
    end

    if constraints.present?
      constraints.each do |constraint|
        next unless constraint.class.ancestors.include?(ActiveRecord::Base)

        role_dependencies = self.role_dependencies.includes({user_role: [:role]}).where(role_dependencies: {role_dependable_type: constraint.class.to_s, role_dependable_id: constraint.id})

        selected_role_dependencies = role_dependencies.select do |role_dependency|
          !role_dependency.is_restriction || (role_dependency.start_date..role_dependency.end_date).include?(Date.today)
        end

        selected_role_dependencies.each do |role_dependency|
          _permissions[role_dependency.user_role.role.name] ||= true
        end
      end
    end

    ActiveSupport::HashWithIndifferentAccess.new(_permissions)
  end

  def user_permissions
    permissions = {}

    Role.pluck(:name).each { |role_name| permissions[role_name] = [] }

    role_dependencies.includes({user_role: [:role]}).where("role_dependencies.start_date <= ? AND role_dependencies.end_date >= ?", Time.zone.now.to_date, Time.zone.now.to_date).each do |role_dependency|
      permission_constraint = (permissions[role_dependency.user_role.role.name] || []).find { |pc| pc[:constraint] == role_dependency.role_dependable_type }

      if permission_constraint.present?
        permission_constraint[:ids] << role_dependency.role_dependable_id
      else
        permissions[role_dependency.user_role.role.name] << {ids: [role_dependency.role_dependable_id], constraint: role_dependency.role_dependable_type}
      end
    end

    permissions
  end

  def is_country_admin?
    role_dependencies.where("role_dependencies.start_date <= ? AND role_dependencies.end_date >= ? AND role_dependencies.role_dependable_type = ?", Time.zone.now.to_date, Time.zone.now.to_date, "DbCountry").exists?
  end

  # Overriding method to allow authenication by using syid
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login_id = conditions.delete(:username).strip
    return if login_id.blank?

    FindSadhakProfile.by_query(login_id)&.user
  end

  def update_reset_password_token
    set_reset_password_token
    reset_password_token
  end

  # Development and testing purpose only
  def self.groped_collection_by_role
    roles = {}

    Role.dependent.each do |role|
      role_name = role.name.to_sym

      UserRole.where(role: role).each do |user_role|
        selected_role_dependencies = user_role.role_dependencies.select do |role_dependency|
          !role_dependency.is_restriction || (role_dependency.start_date..role_dependency.end_date).include?(Date.today)
        end

        if selected_role_dependencies.present?
          roles[role_name] ||= []

          roles[role_name] << user_role.user

          roles[role_name] = roles[role_name].uniq
        end
      end
    end

    roles.merge({
      full_admin: User.where(super_admin: true, event_admin: true, india_admin: true, club_admin: true).limit(5),
      super_admin: User.where(super_admin: true).limit(5),
      event_admin: User.where(event_admin: true).limit(5),
      india_admin: User.where(india_admin: true).limit(5),
      forum_admin: User.where(club_admin: true).limit(5),
      only_super_admin: User.where(super_admin: true, event_admin: false, india_admin: false, club_admin: false).limit(5),
      only_event_admin: User.where(super_admin: false, event_admin: true, india_admin: false, club_admin: false).limit(5),
      only_india_admin: User.where(super_admin: false, event_admin: false, india_admin: true, club_admin: false).limit(5),
      only_forum_admin: User.where(super_admin: false, event_admin: false, india_admin: false, club_admin: true).limit(5),
      normal_user: User.where(super_admin: false, event_admin: false, india_admin: false, club_admin: false).limit(5),
    }).reject { |k, v| v.size.zero? }.collect { |k, v| [k.to_s.titleize.to_sym, v] }.to_h
  end

  def collections_for_chrome_extension

    digital_assets = DigitalAsset.where("digital_assets.published_on <= :current_date AND digital_assets.expires_at >= :current_date", { current_date: Date.today }).includes(DigitalAsset.includable_data)

    unless super_admin? or digital_store_admin? or club_admin?
      language = sadhak_profile.try(:sy_clubs).try(:first).try(:content_type).to_s.split(',')
      digital_assets = digital_assets.filter({ language: language })
    end

    sy_club = sadhak_profile.try(:sy_clubs).try(:first) || sadhak_profile.try(:advisory_counsil).try(:sy_club)

    # Check is_valid_board_member?
    is_valid_board_member = (sy_club.present? and (sadhak_profile.try(:active_club_ids) || []).size > 0 and sy_club.has_board_members_paid and sy_club.active_members_count >= sy_club.min_members_count)

    # Check can_view_shivir_collection?
    can_view_shivir_collection = sadhak_profile.can_view_shivir_collection

    show_video_id = true

    unless super_admin? || digital_store_admin? || club_admin?

      if is_valid_board_member && can_view_shivir_collection
        digital_assets = digital_assets.select{ |asset| asset.collection.forum? } + sadhak_profile.accessable_shivir_episodes
      elsif is_valid_board_member
        digital_assets = digital_assets.select{ |asset| asset.collection.forum? }
      elsif can_view_shivir_collection
        digital_assets = sadhak_profile.accessable_shivir_episodes
      else
        digital_assets = []
      end

      accessible_shivir_type_episodes = sadhak_profile.accessible_shivir_type_episodes
      digital_assets = digital_assets + accessible_shivir_type_episodes if accessible_shivir_type_episodes.present?
    end

    Collection.where(id: digital_assets.try(:uniq).try(:pluck, :collection_id)).includes(:digital_assets).where("digital_assets.id IN (?)", digital_assets.try(:uniq).try(:pluck, :id)).references(:digital_assets)

  end

  def send_extension_asset_report(report_params = {})

    raise SyException, "Params cannot be blank." unless report_params.present?

    raise SyException , "No Asset found with provided #{report_params[:asset_id]} id." unless asset = DigitalAsset.find_by_id(report_params[:asset_id])

    sy_club = SyClub.find_by_id(report_params[:sy_club_id])

    sadhak_profile_address = sadhak_profile.try(:address)

    if sy_club.present?
      from = to = (sy_club.try(:address).try(:country_id) == 113) ? ENV['CHROME_EXTENSION_INDIA_MAILER'] : ENV['CHROME_EXTENSION_GLOBAL_MAILER']
    elsif sadhak_profile_address.present?
      from = to = (sadhak_profile_address.try(:country_id) == 113) ? ENV['CHROME_EXTENSION_INDIA_MAILER'] : ENV['CHROME_EXTENSION_GLOBAL_MAILER']
    end

    to = sadhak_profile.try(:email) if Rails.env == 'development'

    cc = sadhak_profile.try(:email)

    ApplicationMailer.send_email(from: from, recipients: to, cc: cc, subject: "Chrome App Error : #{sadhak_profile.try(:syid)} - #{sy_club.try(:id)}", template: "chrome_asset_report", sadhak_profile: sadhak_profile, content: report_params[:content], asset: asset, sy_club: sy_club).deliver_later

  end

end
