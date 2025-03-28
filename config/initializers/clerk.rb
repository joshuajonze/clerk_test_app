# config/initializers/clerk.rb
Clerk.configure do |c|
    c.secret_key = Rails.application.credentials.clerk[:secret_key]
    c.publishable_key = Rails.application.credentials.clerk[:publishable_key]
  end