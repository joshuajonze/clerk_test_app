# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  include Clerk::Authenticatable

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

  def destroy
    # Check if we have a session
    if clerk.session?
      begin
        # Get the SDK instance
        sdk = Clerk::SDK.new
        
        # Revoke the current session using the session ID
        session_id = clerk.session["id"]
        sdk.sessions.revoke_session(session_id)
        
        # Clear Rails session
        reset_session
        
        # Redirect to home with success message
        redirect_to root_path, notice: "You have been successfully signed out."
      rescue => e
        # Log the error
        Rails.logger.error "Error revoking Clerk session: #{e.message}"
        
        # Clear Rails session anyway and redirect
        reset_session
        redirect_to root_path, alert: "Sign out was partially successful. You may need to clear your browser cookies."
      end
    else
      # No session found, just reset Rails session and redirect
      reset_session
      redirect_to root_path, notice: "You have been signed out."
    end
  end

  def direct_sign_out
    # Reset the Rails session - this is the most reliable part
    reset_session
    
    # Respond with a simple success
    render json: { success: true }
  end
end