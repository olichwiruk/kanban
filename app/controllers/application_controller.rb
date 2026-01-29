class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :store_user_location!, if: :storable_location?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  private def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  private def user_not_authorized
    flash[:alert] = "Access denied"

    respond_to do |format|
      format.html do
        redirect_to request.referrer || root_path, status: :see_other
      end

      format.turbo_stream do
        render turbo_stream: turbo_stream_action_redirect(root_path)
      end
    end
  end

  private def turbo_stream_action_redirect(url)
    turbo_stream.append_all "body", <<~HTML.html_safe
      <script>window.Turbo.visit("#{url}")</script>
    HTML
  end
end
