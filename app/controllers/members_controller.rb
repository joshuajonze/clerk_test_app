# app/controllers/members_controller.rb (updated)
class MembersController < ApplicationController
  before_action :authenticate_user
  before_action :set_member, only: [:show, :edit, :update, :approve, :suspend, :promote]
  before_action :ensure_can_manage, only: [:index, :approve, :suspend]
  before_action :ensure_admin, only: [:promote]
  
  def index
    @filter = params[:filter] || 'all'
    
    @members = case @filter
      when 'pending'
        Member.where(account_status: 'pending').order(created_at: :desc)
      when 'active'
        Member.where(account_status: 'active').order(created_at: :desc)
      when 'suspended'
        Member.where(account_status: 'suspended').order(created_at: :desc)
      else
        Member.all.order(created_at: :desc)
      end
  end
  
  def show
    # Only admins/managers or the member themselves can view profiles
    unless current_member.can_manage? || @member.id == current_member.id
      redirect_to dashboard_members_path, alert: 'You do not have permission to view that profile.'
    end
  end
  
  def new
    @member = Member.new
  end
  
  def create
    # This is handled by Clerk webhook in production
    # For development, we can create test members
    @member = Member.new(member_params)
    
    if @member.save
      redirect_to @member, notice: 'Member was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    # Only admins/managers or the member themselves can edit profiles
    unless current_member.can_manage? || @member.id == current_member.id
      redirect_to dashboard_members_path, alert: 'You do not have permission to edit that profile.'
    end
  end
  
  def update
    # Only allow role changes by admins
    if member_params.key?(:role) && !current_member.admin?
      redirect_to @member, alert: 'Only administrators can change member roles.'
      return
    end
    
    if @member.update(member_params)
      redirect_to @member, notice: 'Member profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def dashboard
    @member = current_member
    
    if @member.can_manage?
      # For admin/manager: show counts for different member statuses
      @pending_count = Member.where(account_status: 'pending').count
      @active_count = Member.where(account_status: 'active').count
      @suspended_count = Member.where(account_status: 'suspended').count
      
      # Show recent pending members
      @recent_pending = Member.where(account_status: 'pending').order(created_at: :desc).limit(5)
    end
    
    # For everyone: display relevant community information
    # This will be expanded later
  end
  
  def approve
    @member.update(account_status: 'active')
    redirect_to members_path(filter: 'pending'), notice: "#{@member.full_name} was successfully approved."
  end
  
  def suspend
    @member.update(account_status: 'suspended')
    redirect_to members_path, notice: "#{@member.full_name} was successfully suspended."
  end
  
  def promote
    @member.update(role: params[:role])
    redirect_to @member, notice: "#{@member.full_name} was promoted to #{params[:role]}."
  end
  
  private
  
  def set_member
    @member = Member.find(params[:id])
  end
  
  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :property_address, :role, :account_status)
  end
  
  def authenticate_user
    redirect_to root_path, alert: 'You must be logged in to access this page.' unless clerk.user?
  end
  
  def current_member
    @current_member ||= Member.find_by(clerk_user_id: clerk.user['id']) if clerk.user?
  end
  
  def ensure_can_manage
    @current_member = current_member
    redirect_to root_path, alert: 'You do not have permission to access this page.' unless @current_member&.can_manage?
  end
  
  def ensure_admin
    @current_member = current_member
    redirect_to root_path, alert: 'Only administrators can perform this action.' unless @current_member&.admin?
  end
end