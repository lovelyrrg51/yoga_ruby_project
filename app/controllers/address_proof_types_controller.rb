class AddressProofTypesController < ApplicationController

  before_action :set_address_proof_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @address_proof_type = AddressProofType.new

    authorize(@address_proof_type)

    if filtering_params.present?

      locate_collection

    else

      @address_proof_types = AddressProofType.page(params[:page]).per(params[:per_page]).order('address_proof_types.name ASC')

    end

  end

  def edit

    authorize(@address_proof_type)

  end

  def create

    @address_proof_type = AddressProofType.new(address_proof_type_params)

    authorize(@address_proof_type)

    if @address_proof_type.save
      flash[:success] = "Address Proof Type was successfully created."
    else
      flash[:error] = @address_proof_type.errors.full_messages.first
    end

    redirect_to address_proof_types_path

  end

  def update

    authorize(@address_proof_type)

    if @address_proof_type.update(address_proof_type_params)
      flash[:success] = "Address Proof Type was successfully updated."
    else
      flash[:error] = @address_proof_type.errors.full_messages.first
    end

    redirect_to address_proof_types_path

  end

  def destroy

    authorize(@address_proof_type)

    if @address_proof_type.destroy
      flash[:success] = "Address Proof Type was successfully destroyed."
    else
      flash[:error] = @address_proof_type.errors.full_messages.first
    end

    redirect_to address_proof_types_path

  end

  private

  def locate_collection
    @address_proof_types = AddressProofTypePolicy::Scope.new(current_user, AddressProofType).resolve(filtering_params).order('address_proof_types.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_address_proof_type
    @address_proof_type = AddressProofType.find(params[:id])
  end

  def address_proof_type_params
      params.require(:address_proof_type).permit(:name)
  end

  def filtering_params
    params.slice(:address_proof_type_name)
  end

end
