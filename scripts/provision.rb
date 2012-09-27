#!/usr/bin/env ruby

DIR='/home/ubuntu/documentcloud/'
LOGIN_EMAIL = 'testing@documentcloud.org'
TESTING_PW  = 'testing42'

Dir.chdir DIR

require "./config/environment"
require 'sqlite3'
require 'cloud-crowd'

organization = Organization.find_by_slug( 'test' )
if organization.nil?
    organization = Organization.create!({:name=>'Testing',:slug=>'test'})
    puts "Created Testing organization, id: #{organization.id}"
end

account = Account.find_by_email( LOGIN_EMAIL )
if account.nil?
    account=Account.create!({:organization=>organization,:first_name=>'Testing',:last_name=>'Account', :email=>LOGIN_EMAIL, \
                             :hashed_password=>BCrypt::Password.create( TESTING_PW ), :role=>Account::ADMINISTRATOR })
    puts "Created Testing account.  Login: #{LOGIN_EMAIL}, pw: #{TESTING_PW}, id: #{account.id}"
end

# the cloud crowd test server will need this
db = SQLite3::Database.new( "#{DIR}cloud_crowd.db" )
exists = db.get_first_value( "SELECT name FROM sqlite_master WHERE type='table' AND name='schema_migrations'" )
if exists.nil?

    puts "Creating schema_migrations table in #{DIR}cloud_crowd.db and running migrations"

    db.execute( "CREATE TABLE schema_migrations (version varchar(255) NOT NULL)" )

   CloudCrowd.configure("config/cloud_crowd/development/config.yml")
    require 'cloud_crowd/models'
    CloudCrowd.configure_database("config/cloud_crowd/development/database.yml", false)
    require 'cloud_crowd/schema.rb'

end
db.close
