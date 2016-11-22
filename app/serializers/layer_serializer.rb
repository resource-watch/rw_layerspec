# frozen_string_literal: true
class LayerSerializer < ApplicationSerializer
  attributes :id, :slug, :user_id, :application, :name, :default, :dataset, :provider, :iso, :description,
             :layerConfig, :legendConfig, :applicationConfig

  def application
    object.try(:app_txt)
  end

  def dataset
    object.try(:dataset_id)
  end

  def provider
    object.try(:provider_txt)
  end

  def user_id
    object.try(:user_id)
  end

  def layerConfig
    object.layer_config == '{}' ? nil : object.layer_config
  end

  def legendConfig
    object.legend_config == '{}' ? nil : object.legend_config
  end

  def applicationConfig
    object.application_config == '{}' ? nil : object.application_config
  end
end
