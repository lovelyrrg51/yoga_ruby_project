module Api::V1
  class AspectFeedbacksController < BaseController
    before_action :set_aspect_feedback, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /aspect_feedbacks
    # GET /aspect_feedbacks.json
    def index
      @aspect_feedbacks = AspectFeedback.all
    end
  
    # GET /aspect_feedbacks/1
    # GET /aspect_feedbacks/1.json
    def show
    end
  
    # GET /aspect_feedbacks/new
    def new
      @aspect_feedback = AspectFeedback.new
    end
  
    # GET /aspect_feedbacks/1/edit
    def edit
    end
  
    # POST /aspect_feedbacks
    # POST /aspect_feedbacks.json
    def create
      @aspect_feedback = AspectFeedback.new(aspect_feedback_params)
  
      respond_to do |format|
        if @aspect_feedback.save
          format.html { redirect_to @aspect_feedback, notice: 'Aspect feedback was successfully created.' }
          format.json { render :show, status: :created, location: @aspect_feedback }
        else
          format.html { render :new }
          format.json { render json: @aspect_feedback.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /aspect_feedbacks/1
    def update
      if @aspect_feedback.update(aspect_feedback_params)
        render json: @aspect_feedback
      else
        render json: @aspect_feedback.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /aspect_feedbacks/1
    # DELETE /aspect_feedbacks/1.json
    def destroy
      @aspect_feedback.destroy
      respond_to do |format|
        format.html { redirect_to aspect_feedbacks_url, notice: 'Aspect feedback was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_aspect_feedback
        @aspect_feedback = AspectFeedback.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def aspect_feedback_params
        params[:aspect_feedback]
        params.require(:aspect_feedback).permit(:rating_before, :rating_after, :name)
      end
  end
end
