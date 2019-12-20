# frozen_string_literal: true

class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :validate_header

  private

  def validate_header
    if request.headers['Content-Type'] != 'application/vnd.api+json'
      render json: {}, status: 400
    end
  end
end
