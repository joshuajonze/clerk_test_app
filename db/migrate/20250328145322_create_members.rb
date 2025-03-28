# This migration creates the members table for the Quail Creek HOA application
class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.string :clerk_user_id, null: false, index: { unique: true }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :property_address, null: false
      t.string :account_status, null: false, default: 'pending'
      t.boolean :is_admin, null: false, default: false
      
      t.timestamps
    end
  end
end