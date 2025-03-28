class Member < ApplicationRecord
    validates :clerk_user_id, presence: true, uniqueness: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :property_address, presence: true
    validates :account_status, presence: true, inclusion: { in: ['pending', 'active', 'suspended'] }
    
    # Status helpers
    def pending?
      account_status == 'pending'
    end
    
    def active?
      account_status == 'active'
    end
    
    def suspended?
      account_status == 'suspended'
    end
    
    # Name helpers
    def full_name
      "#{first_name} #{last_name}"
    end
    
    # Class method to find or create a member from Clerk user data
    def self.from_clerk(clerk_user)
      member = find_by(clerk_user_id: clerk_user['id']) || 
               find_by(email: clerk_user['email_addresses'].find { |e| e['id'] == clerk_user['primary_email_address_id'] }['email_address'])
      
      if member
        # Update member information if it exists
        member.update(
          first_name: clerk_user['first_name'],
          last_name: clerk_user['last_name'],
          email: clerk_user['email_addresses'].find { |e| e['id'] == clerk_user['primary_email_address_id'] }['email_address']
        )
      else
        # Create new member
        member = create(
          clerk_user_id: clerk_user['id'],
          first_name: clerk_user['first_name'],
          last_name: clerk_user['last_name'],
          email: clerk_user['email_addresses'].find { |e| e['id'] == clerk_user['primary_email_address_id'] }['email_address'],
          property_address: '',
          account_status: 'pending'
        )
      end
      
      member
    end
  end