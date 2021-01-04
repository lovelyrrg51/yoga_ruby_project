class AspectFeedbacksController < ApplicationController

  before_action :authenticate_user!

  def update

    begin

      aspect_feedback_params.each do |id,update_attr|

        update_attr.keys.each{ |key|  update_attr[key] = update_attr[key].to_i }

        af = AspectFeedback.find_by_id(id.to_i)

        af.update!(update_attr)

      end
      
    rescue Exception => e

      logger.info(" Exception in aspect feedback controller update action: #{e.message}")
      flash[:alert] = "Sadhak Profile is not updated."

    end
    redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_aspect_feedback_sp_accordion_id])

  end

  private

  def aspect_feedback_params
    params.require(:aspect_feedback).permit!
  end

end