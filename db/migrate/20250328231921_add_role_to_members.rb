# db/migrate/[timestamp]_add_role_to_members.rb
class AddRoleToMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :members, :role, :string, null: false, default: 'member'
    add_index :members, :role
    add_index :members, :account_status
  end
end