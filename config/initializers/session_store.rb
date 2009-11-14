# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_CoreData_session',
  :secret      => 'c47ffda3dbd8d8cd9f9b9ff7d76c08be1947d1b564fa525e9a82ab75ee498d1caf324d027447ea36c7d7384f4c2318b8beeca96c55cec034621cff08142d3977'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
