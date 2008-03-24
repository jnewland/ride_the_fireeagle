begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$LOAD_PATH.unshift 'lib/'

require 'rubygems'
require 'multi_rails_init'

RAILS_ROOT = File.dirname(__FILE__) unless defined? RAILS_ROOT
RAILS_ENV  = 'test' unless defined? RAILS_ENV
 
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']
ActionController::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.column :username, :string
    t.column :fireeagle_request_token, :string
    t.column :fireeagle_request_token_secret, :string
    t.column :fireeagle_access_token, :string
    t.column :fireeagle_access_token_secret, :string
  end
end

require 'fireeagle'
require 'ride_the_fireeagle'
ActiveRecord::Base.send(:include, RideTheFireeagle)

class User < ActiveRecord::Base
  ride_the_fireeagle
end