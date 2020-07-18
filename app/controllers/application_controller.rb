class ApplicationController < ActionController::Base

  rescue_from RuntimeError do |exception|
    @error = exception
  end
end
