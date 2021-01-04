module Api::V1
  class AttachmentsController < BaseController
    before_action :authenticate_user!
    before_action :set_attachment, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /attachments
    def index
      @attachments = Attachment.all
      render json: @attachments
    end
  
    # GET /attachments/1
    def show
    end
  
    # GET /attachments/new
    def new
      @attachment = Attachment.new
    end
  
    # GET /attachments/1/edit
    def edit
    end
  
    # POST /attachments
    def create
      t = Time.now.to_i.to_s
      folder_path = ENV['TICKET_RESPONSE_ATTACHMENT_PATH']
      file = params['file'].tempfile.path
      s3_bucket = ENV['ATTACHMENT_BUCKET']
      file_name = params['file'].original_filename
      file_type = params[:file].content_type
      @attachment = Attachment.upload_file(file_name: file_name, content: file, is_secure: false, bucket_name: s3_bucket,  attachable_id: params[:attachable_id], attachable_type: params[:attachable_type], file_type: file_type, prefix: folder_path)
      if @attachment
        render json: @attachment
      else
        render json: {error: 1, message: "Image could not be saved"}, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /attachments/1
    def update
      if @attachment.update(attachment_params)
        render json: @attachment
      else
        render json: @attachment.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /attachments/1
    def destroy
      aa = @attachment.destroy
      render json: aa
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_attachment
        @attachment = Attachment.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def attachment_params
        params.require(:attachment).permit(:name, :file_type, :file_size, :s3_url, :s3_path, :s3_bucket, :is_secure, :attachable_id, :attachable_type)
      end
  end
end
