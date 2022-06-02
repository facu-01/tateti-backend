class ApplicationController < ActionController::API

  def get_response(message:, status: 200, data: nil)
    if data
      render status:, json: { message:, data: }
    else
      render status:, json: { message: }
    end
  end
end
