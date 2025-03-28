# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
    def after_signup
      if clerk.user?
        # Create or update member from Clerk user
        @member = ClerkMemberService.create_or_update_from_clerk_user(clerk.user)
        
        # If this is a new member that needs to complete their profile
        if @member.property_address.blank?
          redirect_to edit_member_path(@member), notice: 'Please complete your profile'
        else
          redirect_to dashboard_members_path, notice: 'Welcome to Quail Creek HOA!'
        end
      else
        redirect_to root_path, alert: 'Authentication required'
      end
    end
  end