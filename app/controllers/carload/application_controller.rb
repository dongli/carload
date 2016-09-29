module Carload
  class ApplicationController < ::ApplicationController
    include Pundit
    rescue_from Pundit::NotAuthorizedError, with: :rescue_not_authorized_error

    protect_from_forgery with: :exception

    # For demo only!
    if Carload.auth_solution == :none
      def current_user
        nil
      end
    end

    private

    def rescue_not_authorized_error
      if Carload.auth_solution == :devise
        if user_signed_in?
          message = I18n.t("carload.error.message.#{params[:controller].split('/').last}_#{params[:action]}")
          redirect_to unauthorized_error_path(message: message)
        else
          authenticate_user!
        end
      end
    end
  end
end
