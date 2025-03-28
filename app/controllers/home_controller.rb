# app/controllers/home_controller.rb
class HomeController < ApplicationController
    def index
      @user = clerk.user if clerk.user?
    end
  end