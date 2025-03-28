# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Clerk::Authenticatable
end

# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @user = clerk.user if clerk.user?
  end
end