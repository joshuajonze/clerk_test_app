# app/services/clerk_member_service.rb
class ClerkMemberService
    def self.create_or_update_from_clerk_user(clerk_user)
      # Find existing member by clerk_user_id or email
      member = Member.find_by(clerk_user_id: clerk_user['id']) || 
               Member.find_by(email: clerk_user['email_addresses'].find { |e| e['id'] == clerk_user['primary_email_address_id'] }['email_address'])
      
      if member
        # Update member information if it exists
        member.update(
          first_name: clerk_user['first_name'],
          last_name: clerk_user['last_name'],
          email: clerk_user['email_addresses'].find { |e| e['id'] == clerk_user['primary_email_address_id'] }['email_address']
        )
      else
        # Create new member
        member = Member.create(
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