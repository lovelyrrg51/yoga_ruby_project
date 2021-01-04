module V2
  class BlogsController < BaseController
    before_action :get_post, only: [:create]
    def index
      @posts = Comfy::Blog::Post.where(is_published: true).order(published_at: :desc)
    end

    def show
      @post = Comfy::Blog::Post.find_by_slug(params[:id]) || Comfy::Blog::Post.find_by_id(params[:id])
      @recent_posts = Comfy::Blog::Post.last(5)
      @previous_post = Comfy::Blog::Post.previous_post(@post&.id).last
      @next_post = Comfy::Blog::Post.next_post(@post&.id).first
      @comment = Comment.new
    end

    def create
      if @post.present?
        comment = @post.comments.new(comment_params)
        if comment.save
          flash[:success] = "Comment is created successfully"
          redirect_to v2_blog_path(comment.post.slug)
          else
            redirect_to v2_blog_path(comment.post.slug), flash: { error:  comment.errors.full_messages.join('<br>') }

        end
      else
        redirect_back(fallback_location: root_path, flash: { error:  'Post must present'})
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:name, :email, :comment)
    end

    def get_post
      @post = Comfy::Blog::Post.find_by(id: params[:id])
    end
  end
end
