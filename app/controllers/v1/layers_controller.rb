# frozen_string_literal: true
module V1
  class LayersController < ApplicationController
    include ParamsHandler

    before_action :set_layer,  only: [:show, :update, :destroy]
    before_action :set_user,   except: [:index, :show, :by_datasets]
    before_action :set_caller, only: :update

    def index
      @layers = Layer.fetch_all(layer_type_filter)
      render json: @layers, each_serializer: LayerSerializer, meta: { layersCount: @layers.size }
    end

    def by_datasets
      @layers = Layer.fetch_by_datasets(layer_datasets_filter)
      render json: @layers, each_serializer: LayerSerializer, meta: { layersCount: @layers.size }
    end

    def show
      render json: @layer, serializer: LayerSerializer, meta: { status: @layer.try(:status_txt),
                                                                published: @layer.try(:published),
                                                                updatedAt: @layer.try(:updated_at),
                                                                createdAt: @layer.try(:created_at) }
    end

    def update
      if @authorized.present?
        if @layer.update(@layer_params)
          render json: @layer, status: 200, serializer: LayerSerializer, meta: { status: @layer.try(:status_txt),
                                                                                 published: @layer.try(:published),
                                                                                 updatedAt: @layer.try(:updated_at),
                                                                                 createdAt: @layer.try(:created_at) }
        else
          render json: { success: false, message: @layer.errors.full_messages }, status: 422
        end
      else
        render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401
      end
    end

    def create
      authorized = User.authorize_user!(@user, @layer_apps)
      if authorized.present?
        @layer = Layer.new(layer_params.except(:logged_user))
        if @layer.save
          render json: @layer, status: 201, serializer: LayerSerializer, meta: { status: @layer.try(:status_txt),
                                                                                 published: @layer.try(:published),
                                                                                 updatedAt: @layer.try(:updated_at),
                                                                                 createdAt: @layer.try(:created_at) }
        else
          render json: { success: false, message: @layer.errors.full_messages }, status: 422
        end
      else
        render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401
      end
    end

    def destroy
      authorized = User.authorize_user!(@user, intersect_apps(@layer.application.split(','), @apps), @layer.try(:user_id), match_apps: true)
      if authorized.present?
        if @layer.destroy
          render json: { success: true, message: 'Layer deleted' }, status: 200
        else
          return render json: @layer.erors, message: 'Layer could not be deleted', status: 422
        end
      else
        render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401
      end
    end

    private

      def set_layer
        @layer = Layer.set_by_id_or_slug(params[:id])
        if @layer.blank? || (params[:dataset_id].present? && @layer.dataset_id != params[:dataset_id])
          record_not_found
        end
      end

      def intersect_apps(layer_apps, user_apps, additional_apps=nil)
        if additional_apps.present?
          if (layer_apps | additional_apps).uniq.sort == (user_apps & (layer_apps | additional_apps)).uniq.sort
            layer_apps | additional_apps
          else
            ['apps_not_authorized'] if layer_params[:logged_user][:id] != 'microservice'
          end
        else
          layer_apps
        end
      end

      def set_user
        if ENV.key?('OLD_GATEWAY') && ENV.fetch('OLD_GATEWAY').include?('true')
          User.data = [{ user_id: '123-123-123', role: 'superadmin', apps: nil }]
          @user= User.last
        elsif params[:logged_user].present? && params[:logged_user][:id] != 'microservice'
          user_id      = params[:logged_user][:id]
          @role        = params[:logged_user][:role].downcase
          @apps        = if @role.include?('superadmin')
                           ['AllApps']
                         elsif params[:logged_user][:extra_user_data].present? && params[:logged_user][:extra_user_data][:apps].present?
                           params[:logged_user][:extra_user_data][:apps].map { |v| v.downcase }.uniq
                         end
          @layer_apps  = if action_name != 'destroy' && layer_params[:application].present?
                           layer_params[:application].downcase.split(',')
                          end

          User.data = [{ user_id: user_id, role: @role, apps: @apps }]
          @user = User.last
        else
          render json: { errors: [{ status: 401, title: 'Not authorized!' }] }, status: 401 if params[:logged_user][:id] != 'microservice'
        end
      end

      def set_caller
        if layer_params[:logged_user].present? && layer_params[:logged_user][:id] == 'microservice'
          @layer_params = layer_params.except(:user_id, :logged_user)
          @authorized = true
        else
          @layer_params = layer_params.except(:logged_user)
          @authorized = User.authorize_user!(@user, intersect_apps(@layer.application.split(','), @apps, @layer_apps), @layer.try(:user_id), match_apps: true)
        end
      end

      def layer_type_filter
        params.permit(:status, :published, :app, :dataset)
      end

      def layer_datasets_filter
        params.require(:layer).permit(ids: [], app: [])
      end

      def layer_params
        layer_params_sanitizer.tap do |layer_params|
          layer_params[:dataset_id] = params[:dataset_id] if params[:dataset_id].present?
        end
      end
  end
end
