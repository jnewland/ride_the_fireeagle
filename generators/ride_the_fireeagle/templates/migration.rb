class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    add_column "<%= table_name %>", :request_token, :string
    add_column "<%= table_name %>", :request_token_secret, :string
    add_column "<%= table_name %>", :access_token, :string
    add_column "<%= table_name %>", :access_token_secret, :string
  end
 
  def self.down
    remove_column "<%= table_name %>", :request_token
    remove_column "<%= table_name %>", :request_token_secret
    remove_column "<%= table_name %>", :access_token
    remove_column "<%= table_name %>", :access_token_secret
  end
end