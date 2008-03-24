module RideTheFireeagle
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end

  module ClassMethods
    def ride_the_fireeagle(options = {})
      #load up the config file
      @@fireeagle_config_path = options[:fireeagle_config_path] || (RAILS_ROOT + '/config/fireeagle.yml')
      @@fireeagle_config ||= YAML.load_file(@@fireeagle_config_path)["fireeagle"].symbolize_keys
      
      include InstanceMethods
    end
    
    def fireeagle
      FireEagle::Client.new(
        :consumer_key => fireeagle_config[:consumer_key], 
        :consumer_secret => fireeagle_config[:consumer_secret],
        :app_id => fireeagle_config[:mobile_app_id], 
        :access_token => fireeagle_config[:general_purpose_access_token],
        :access_token_secret => fireeagle_config[:general_purpose_token_secret]
      )
    end
    
    def find_fireeagle_recent(args = {})
      args = {:limit => 10, :offset => 0, :time => 'now'}.merge(args)
      fe_users = fireeagle.recent(args[:limit], args[:offset], args[:time]) rescue []
      convert_fe_users_to_ar_objects(fe_users)
    end
    
    def find_fireeagle_within(location = {}, args = {})
      args = {:limit => 10, :offset => 0}.merge(args)
      fe_users = fireeagle.within(location, args[:limit], args[:offset]) rescue []
      convert_fe_users_to_ar_objects(fe_users)
    end
    
    def fireeagle_config
      @@fireeagle_config
    end
    
  private
  
    def convert_fe_users_to_ar_objects(fe_users)
      users = []
      fe_users.each do |fe_user|
        user = find_by_fireeagle_access_token(fe_user.token)
        users << user unless user.nil?
      end
      users
    end
    
  end
  
  module InstanceMethods
    def fireeagle_config
      self.class.fireeagle_config
    end

    def has_request_token_from_fireeagle?
      !self.fireeagle_request_token.blank? && !self.fireeagle_request_token_secret.blank?
    end

    def authorized_with_fireeagle?
      !self.fireeagle_access_token.blank? && !self.fireeagle_access_token_secret.blank?
    end

    def get_fireeagle_request_token
      token = self.fireeagle.get_request_token(true)
      self.update_attributes(:fireeagle_request_token => token.token, :fireeagle_request_token_secret => token.secret, :fireeagle_access_token => nil, :fireeagle_access_token_secret => nil)
      return token.token
    end

    def fireeagle_authorization_url
      return nil unless self.has_request_token_from_fireeagle?
      self.fireeagle.authorization_url
    end

    def authorize_with_fireeagle
      return false unless self.has_request_token_from_fireeagle?
      begin
        token = self.fireeagle.convert_to_access_token
        self.update_attributes(:fireeagle_request_token => nil, :fireeagle_request_token_secret => nil, :fireeagle_access_token => token.token, :fireeagle_access_token_secret => token.secret)
        return true
      rescue
        return false
      end
    end

    def update_location(q)
      return false unless self.authorized_with_fireeagle?
      self.fireeagle.update(:q => q).success?
    end

    def location
      return false unless self.authorized_with_fireeagle?
      begin
        return @location ||= self.fireeagle.user.best_guess
      rescue
        return nil
      end
    end
  
  private
    
    def fireeagle
      if self.authorized_with_fireeagle?
        FireEagle::Client.new(
          :consumer_key => self.fireeagle_config[:consumer_key], 
          :consumer_secret => self.fireeagle_config[:consumer_secret],
          :app_id => self.fireeagle_config[:mobile_app_id], 
          :access_token => self.fireeagle_access_token,
          :access_token_secret => self.fireeagle_access_token_secret
        )
      elsif self.has_request_token_from_fireeagle?
        FireEagle::Client.new(
          :consumer_key => self.fireeagle_config[:consumer_key], 
          :consumer_secret => self.fireeagle_config[:consumer_secret],
          :app_id => self.fireeagle_config[:mobile_app_id], 
          :request_token => self.fireeagle_request_token,
          :request_token_secret => self.fireeagle_request_token_secret
        )
      else
        FireEagle::Client.new(
          :consumer_key => self.fireeagle_config[:consumer_key],
          :consumer_secret => self.fireeagle_config[:consumer_secret],
          :app_id => self.fireeagle_config[:mobile_app_id]
        )
      end
    end
  
  end
end