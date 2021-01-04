module CmsDeviseAuth
  def authenticate
    unless current_user && (current_user.super_admin? || current_user.india_admin?)
      if current_user.nil?
        redirect_to new_user_session_path
      else
        redirect_to root_path
      end
    end
  end
end