require_dependency 'carload/application_controller'

module Carload
  class DashboardController < ApplicationController
    layout 'carload/dashboard'
    rescue_from ActionView::MissingTemplate, with: :rescue_missing_template
    rescue_from Carload::UnmanagedModelError, with: :rescue_unmanaged_model_error

    before_action :set_model
    before_action :set_object, only: [:edit, :update, :destroy]
    before_action :transform_polymorphic_params, only: [:create, :update]

    include Croppable
    include ApplicationHelper

    def index
      authorize :carload_dashboard, :index? unless Carload.auth_solution == :none
      if params[:search].present?
        @query = params[:search][:query]
        case Carload.search_engine
        when :elasticsearch
          @objects = @model_class.search(params[:search][:query]).records.page(params[:page])
        when :pg_search
          @objects = @model_class.search(params[:search][:query]).page(params[:page])
        end
      else
        @objects = @model_class.page(params[:page])
      end
      @show_attributes = Dashboard.model(@model_name).index_page[:shows][:attributes] + [:created_at, :updated_at]
      render "dashboard/#{@model_names}/index.html.erb"
    end

    def new
      authorize :carload_dashboard, :new? unless Carload.auth_solution == :none
      @object = @model_class.new
    end

    def edit
      authorize :carload_dashboard, :edit? unless Carload.auth_solution == :none
    end

    def create
      authorize :carload_dashboard, :create? unless Carload.auth_solution == :none
      @object = @model_class.create model_params
      if @object.save
        redirect_to action: :index, model: @model_names # TODO: To show page.
      else
        render :new
      end
    end

    def update
      authorize :carload_dashboard, :update? unless Carload.auth_solution == :none
      if @object.update model_params
        redirect_to action: :index, model: @model_names # TODO: To show page.
      else
        render :edit
      end
    end

    def destroy
      authorize :carload_dashboard, :destroy? unless Carload.auth_solution == :none
      @object.destroy
      redirect_to action: :index, model: @model_names
    end

    def search
      params[:action] = :index # To make rescue_missing_template use correct index action.
      index
    end

    private

    def set_model
      @model_names = ( params[:model] || Dashboard.default_model ).to_s.pluralize
      @model_name = @model_names.singularize.to_sym
      raise Carload::UnmanagedModelError.new(@model_name) if not Dashboard.models.keys.include? @model_name
      @model_class = @model_name.to_s.classify.constantize
    end

    def set_object
      @object = @model_class.find params[:id]
    end

    def model_params
      params.require(@model_name).permit(Dashboard.model(@model_name).attributes[:permitted])
    end

    def rescue_missing_template exception
      render params[:action]
    end

    def rescue_unmanaged_model_error exception
      redirect_to dashboard_error_path(message: exception.message)
    end

    def transform_polymorphic_params
      polymorphic_params = {}
      params[@model_name].each do |key, value|
        if polymorphic? key
          polymorphic_params["#{key}_id"], polymorphic_params["#{key}_type"] = value.split(',')
        end
      end
      params[@model_name].merge! polymorphic_params
    end
  end
end
