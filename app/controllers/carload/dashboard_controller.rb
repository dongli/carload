require_dependency "carload/application_controller"

module Carload
  class DashboardController < ::DashboardController
    layout 'carload/application'
    rescue_from ActionView::MissingTemplate, with: :rescue_missing_template
    rescue_from Carload::UnmanagedModelError, with: :rescue_unmanaged_model_error

    before_action :set_model
    before_action :set_object, only: [:edit, :update, :destroy]

    def index
      @search = @model_class.search(params[:q])
      @objects = @search.result.page(params[:page]).per(2)
      @show_attributes = SHOW_ATTRIBUTES_ON_INDEX[@model_name] + [:created_at, :updated_at]
      @search_attributes = SEARCH_ATTRIBUTES_ON_INDEX[@model_name]
      render "dashboard/#{@model_names}/index.html.erb"
    end

    def new
      @object = @model_class.new
    end

    def edit
    end

    def create
      @object = @model_class.create model_params
      if @object.save
        redirect_to action: :index, model: @model_names # TODO: To show page.
      else
        render :new
      end
    end

    def update
      if @object.update model_params
        redirect_to action: :index, model: @model_names # TODO: To show page.
      else
        render :edit
      end
    end

    def destroy
      @object.destroy
      redirect_to action: :index, model: @model_names
    end

    def search
      params[:action] = :index # To make rescue_missing_template use correct index action.
      index
    end

    def error
    end

    private

    def set_model
      @model_names = ( params[:model] || DEFAULT_MODEL ).to_s.pluralize
      @model_name = @model_names.singularize.to_sym
      raise Carload::UnmanagedModelError.new(@model_name) if not MODELS.include? @model_name
      @model_class = @model_name.to_s.classify.constantize
    end

    def set_object
      @object = @model_class.find params[:id]
    end

    def model_params
      params.require(@model_name).permit(PERMITTED_ATTRIBUTES[@model_name])
    end

    def rescue_missing_template exception
      render params[:action]
    end

    def rescue_unmanaged_model_error exception
      @error = exception.instance_values['error']
      render :error
    end
  end
end
