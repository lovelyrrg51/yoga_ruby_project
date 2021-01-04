class PaymentGatewayModeAssociationsController < ApplicationController
  before_action :set_payment_gateway_mode_association, only: [:show, :edit, :update, :destroy]
  before_action :set_ccavenue_config, only: [:new, :destroy, :create, :edit, :update]
  before_action :set_payment_gateway, only: [:create, :edit, :new]
  before_action :set_payment_mode, only: [:new]
  before_action :authenticate_user!, except: [:index]
  before_action :verify_authenticity_token, except: [:index]

  # GET /payment_gateway_mode_associations
  def index
  end

  # GET /payment_gateway_mode_associations/1
  def show
  end

  # GET /payment_gateway_mode_associations/new
  def new

    begin

      raise "No Payment Gateway is Associated with this Config." unless @payment_gateway.present?

      @payment_gateway_mode_association = @payment_gateway.payment_gateway_mode_associations.build(payment_mode_id: @payment_mode.id)

      authorize @payment_gateway_mode_association

      @payment_gateway_mode_association.payment_gateway_mode_association_ranges.build

      @payment_gateway_mode_association.payment_gateway_mode_association_tax_types.build

    rescue Exception => e

      @message = e.message
      
    end

    respond_to do |format|
      format.js
    end

  end

  # GET /payment_gateway_mode_associations/1/edit
  def edit

    authorize @payment_gateway_mode_association

    @payment_mode = @payment_gateway_mode_association.payment_mode

    respond_to do |format|
      format.js { render 'new.js.erb' }
    end

  end

  # POST /payment_gateway_mode_associations
  def create

    begin

      raise "No Payment Gateway Found." unless @payment_gateway.present?

      @payment_gateway_mode_association = @payment_gateway.payment_gateway_mode_associations.build(payment_gateway_mode_association_params)

      authorize @payment_gateway_mode_association

      if @payment_gateway_mode_association.range?

        raise "Please enter the ranges." unless @payment_gateway_mode_association.payment_gateway_mode_association_ranges.present?

        @message = check_range(@payment_gateway_mode_association.payment_gateway_mode_association_ranges.collect{ |range| range[:max_value].infinite? ? range[:min_value].to_i...Float::INFINITY : range[:min_value].to_i...range[:max_value].to_i })

        raise @message if @message.present?

      end

      @payment_gateway_mode_association.save!

    rescue Exception => e

      @message = e.message
      
    end

    @message.present? ? flash[:alert] = @message : flash[:success] = "Payment Mode is Successfully reated."

    redirect_to payment_modes_ccavenue_config_path(@ccavenue_config)

  end

  # PATCH/PUT /payment_gateway_mode_associations/1
  def update

    begin

      authorize @payment_gateway_mode_association

      if payment_gateway_mode_association_params[:percent_type] == "range"

        raise "Please enter the ranges." unless payment_gateway_mode_association_params[:payment_gateway_mode_association_ranges_attributes].present?

        min_max_ranges = payment_gateway_mode_association_params[:payment_gateway_mode_association_ranges_attributes].to_h.with_indifferent_access.values.select{ |range| %w(false 0).include?(range[:_destroy]) }

        raise "Please enter the ranges." unless min_max_ranges.present?

        @message = check_range(min_max_ranges.pluck(:min_value, :max_value).collect{|range| (range[1] == "Infinity") ? range[0].to_i...Float::INFINITY : range[0].to_i...range[1].to_i })

        raise @message if @message.present?

      end

      @payment_gateway_mode_association.update!(payment_gateway_mode_association_params)

    rescue Exception => e

      @message = e.message
      
    end

    @message.present? ? flash[:alert] = @message : flash[:success] = "Payment Mode is Successfully Updated."

    redirect_to payment_modes_ccavenue_config_path(@ccavenue_config)

  end

  # DELETE /payment_gateway_mode_associations/1
  def destroy

    begin

      authorize @payment_gateway_mode_association
      @payment_gateway_mode_association.destroy!
      
    rescue Exception => e

      message = e.message
      
    end
    
    message.present? ? flash[:alert] = message : flash[:success] = "Payment Mode is Successfully Destroyed."
    redirect_back(fallback_location: proc { payment_modes_ccavenue_config_path(@ccavenue_config) })

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payment_gateway_mode_association
    @payment_gateway_mode_association = PaymentGatewayModeAssociation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payment_gateway_mode_association_params
    params.require(:payment_gateway_mode_association).permit(:percent, :percent_type, :payment_gateway_id, :payment_mode_id, payment_gateway_mode_association_ranges_attributes: [:id, :_destroy, :min_value, :max_value, :percent], payment_gateway_mode_association_tax_types_attributes: [:id, :_destroy, :tax_type_id, :percent] )
  end

  def filtering_params
    params.slice(:payment_gateway_id, :payment_mode_id)
  end

  def set_ccavenue_config
    @ccavenue_config = CcavenueConfig.find(params[:ccavenue_config_id])
  end

  def set_payment_gateway
    @payment_gateway = @ccavenue_config.payment_gateway
  end

  def check_range(ranges)

    #ranges = [101..200, 1..Float::INFINITY, 1..100]

    zeroes = ranges.select{|range| range.begin == 0 }

    raise "Please insert a range with Zero." unless zeroes.present?

    raise "No two ranges have 0 as Minimum Value." if zeroes.count > 1

    infy = ranges.select{|range| range.end == Float::INFINITY }

    raise "Please insert an Infinity Range." unless infy.present?

    raise "No two ranges have Infinity as Maximum Value." if infy.count > 1

    infy_range = ranges.select{|range| range.end == Float::INFINITY }.last

    ranges_sum = 0

    (ranges.reject{|range| range.end == Float::INFINITY } || []).each do |range|

      ranges_sum += range.inject(:+).to_i

    end

    raise "Invalid ranges." unless (0..infy_range.begin).inject(:+) == (ranges_sum + infy_range.begin)

  end

  def set_payment_mode
    @payment_mode = PaymentMode.find_by_id(params[:payment_mode_id])
  end

end
