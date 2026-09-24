# frozen_string_literal: true

class ModelsController < ApplicationController
  def index
    @models = available_chat_models
  end

  def show
    @model = Model.find(params.expect(:id))
  end

  def refresh
    RubyLLM.models.refresh
    redirect_to models_path, notice: "Models refreshed successfully"
  end
end
