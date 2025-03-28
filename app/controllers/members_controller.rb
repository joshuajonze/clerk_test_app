class MembersController < ApplicationController
    before_action :authenticate_user, except: [:new, :create]
    before_action :set_member, only: [:show, :edit, :update]
    before_action :ensure_admin, only: [:index, :approve, :suspend]
    
    def index
      @members = Member.all.order(created_at: :desc)
    end
    
    def show
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
    end
    
    def update
      if @member.update(member_params)
        redirect_to @member, notice: 'Member profile was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def dashboard
      @member = current_member
      # We'll add more dashboard data here later
    end
    
    def approve
      @member = Member.find(params[:id])
      @member.update(account_status: 'active')
      redirect_to members_path, notice: 'Member was successfully approved.'
    end
    
    def suspend
      @member = Member.find(params[:id])
      @member.update(account_status: 'suspended')
      redirect_to members_path, notice: 'Member was successfully suspended.'
    end
    
    private
    
    def set_member
      @member = Member.find(params[:id])
    end
    
    def member_params
      params.require(:member).permit(:first_name, :last_name, :email, :property_address)
    end
    
    def authenticate_user
      redirect_to root_path, alert: 'You must be logged in to access this page.' unless clerk.user?
    end
    
    def current_member
      @current_member ||= Member.find_by(clerk_user_id: clerk.user['id']) if clerk.user?
    end
    
    def ensure_admin
      @current_member = current_member
      redirect_to root_path, alert: 'You do not have permission to access this page.' unless @current_member&.is_admin?
    end
  end