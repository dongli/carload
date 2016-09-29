require_dependency 'carload/application_controller'

module Carload
  class ErrorsController < ApplicationController
    layout 'carload/application'

    before_action :set_message

    def dashboard_error
    end

    def unauthorized_error
    end

    private

    def set_message
      @message = params[:message]
    end
  end
end
