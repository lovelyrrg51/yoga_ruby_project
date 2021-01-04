class RoleDependenciesController < ApplicationController
  before_action :set_role_dependency, only: [:show, :edit, :update, :destroy]
  before_action :find_role_dependable, only: [:create]
  before_action :locate_collection, only: [:index]
  before_action :authenticate_user!

  # GET /role_dependencies
  def index
    authorize(:role_dependency, :index?)
    @role_dependency = RoleDependency.new
    @role_dependencies = RoleDependency.where(role_dependable_type: 'Event', role_dependable_id: @event.id)
  end

  # GET /role_dependencies/1
  def show
  end

  # GET /role_dependencies/new
  def new
    @role_dependency = RoleDependency.new
  end

  # GET /role_dependencies/1/edit
  def edit
  end

  # POST /role_dependencies
  def create

    @role_dependency = RoleDependency.new(role_dependency_params.except(:syid, :first_name, :role))

    authorize @role_dependency

    begin

      sadhak_profile = SadhakProfile.where('LOWER(syid) = ? and LOWER(first_name) = ?', "sy#{role_dependency_params[:syid].to_s.strip[/-?\d+/].to_i}".downcase, role_dependency_params[:first_name].to_s.strip.downcase).first

      raise 'Sadhak Profile not found.' unless sadhak_profile.present?

      raise 'Sadhak Profile is not associated with any user.' unless sadhak_profile.user.present?

      role = Role.find_by_name(role_dependency_params[:role].to_s.downcase)

      user_role = UserRole.find_by(user: sadhak_profile.user, role: role)

      unless user_role.present?

        user_role = UserRole.new(user: sadhak_profile.user, role: role)

        raise user_role.errors.full_messages.first unless user_role.save

      end

      @role_dependency.user_role = user_role

      # @role_dependency.role_dependable_type = @role_dependable.class.to_s

      # @role_dependency.role_dependable_id = @role_dependable.id

      raise @role_dependency.errors.full_messages.first unless @role_dependency.save

    rescue Exception => e
      message = e.message
    end

    if message.present?
      flash[:alert] = message
    else
      flash[:notice] = 'Role was successfully created.'
    end

    redirect_back(fallback_location: proc { root_path })

  end

  # PATCH/PUT /role_dependencies/1
  def update
    authorize @role_dependency
    begin

      @event = Event.find(role_dependency_params[:role_dependable_id])
      raise "Event not found." unless @event.present?

      sadhak_profile = SadhakProfile.where('LOWER(syid) = ? and LOWER(first_name) = ?', "sy#{role_dependency_params[:syid].to_s.strip[/-?\d+/].to_i}".downcase, role_dependency_params[:first_name].to_s.strip.downcase).first
      raise 'Sadhak Profile not found.' unless sadhak_profile.present?

      raise 'Sadhak Profile is not associated with any user.' unless sadhak_profile.user.present?

      role = Role.find_by_name(role_dependency_params[:role].to_s.downcase)

      user_role = UserRole.find_by(user: sadhak_profile.user, role: role)

      unless user_role.present?

        user_role = UserRole.new(user: sadhak_profile.user, role: role)

        raise user_role.errors.full_messages.first unless user_role.save

      end

      @role_dependency.user_role = user_role

      @role_dependency.update!(role_dependency_params.except(:syid, :first_name, :role))

    rescue Exception => e
      message = e.message
    end

    if message.present?
      flash[:alert] = e.message
      redirect_back(fallback_location: proc { root_path })
    else
      flash[:success] = "Role dependency was successfully updated."
      redirect_to photo_approval_admin_event_path(@event)
    end

  end

  # DELETE /role_dependencies/1
  def destroy
    authorize @role_dependency
    @role_dependency.destroy
    flash[:notice] = 'Role dependency was successfully destroyed.'
    redirect_back(fallback_location: proc { root_path })
  end

  def locate_collection
    @role_dependencies = RoleDependencyPolicy::Scope.new(current_user, RoleDependency).resolve(filtering_params)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role_dependency
      @role_dependency = RoleDependency.find(params[:id])
    end

    def find_role_dependable
      klass = role_dependency_params[:role_dependable_type].capitalize.constantize
      @role_dependable = klass.find(role_dependency_params[:role_dependable_id])
    end

    # Only allow a trusted parameter "white list" through.
    def role_dependency_params
      params.require(:role_dependency).permit(:start_date, :end_date, :syid, :first_name, :role, :role_dependable_type, :role_dependable_id)
    end

    def filtering_params
      params.slice(:event_id, :role)
    end
end
