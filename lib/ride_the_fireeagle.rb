module RideTheFireeagle
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end

  module ClassMethods
    def ride_the_fireeagle(options = {})
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def init_fireeagle(app_id, consumer_key, consumer_secret)
      if self.authorized?
        @fireeagle = FireEagle::Client.new(
                      :consumer_key => consumer_key, 
                      :consumer_secret => consumer_secret,
                      :app_id => app_id, 
                      :access_token => self.access_token,
                      :access_token_secret => self.access_token_secret)
      elsif self.has_request_token?
        @fireeagle = FireEagle::Client.new(
                      :consumer_key => consumer_key, 
                      :consumer_secret => consumer_secret,
                      :app_id => app_id, 
                      :request_token => self.request_token,
                      :request_token_secret => self.request_token_secret)
      else
        @fireeagle = FireEagle::Client.new(
                      :consumer_key => consumer_key,
                      :consumer_secret => consumer_secret,
                      :app_id => app_id)
      end
    end

    def has_request_token?
      !self.request_token.blank? && !self.request_token_secret.blank?
    end

    def authorized?
      !self.access_token.blank? && !self.access_token_secret.blank?
    end

    def get_request_token
      token = self.fireeagle.get_request_token(true)
      self.update_attributes(:request_token => token.token, :request_token_secret => token.secret, :access_token => nil, :access_token_secret => nil)
      return token.token
    end

    def authorization_url
      return nil unless self.has_request_token?
      self.fireeagle.authorization_url
    end

    def authorize
      return false unless self.has_request_token?
      begin
        token = self.fireeagle.convert_to_access_token
        self.update_attributes(:request_token => nil, :request_token_secret => nil, :access_token => token.token, :access_token_secret => token.secret)
        return true
      rescue
        return false
      end
    end

    def update_location(q)
      return false unless self.authorized?
      self.fireeagle.update(:q => q).success?
    end

    def location
      return false unless self.authorized?
      begin
        response = self.fireeagle.user
        return response.best_guess.name
      rescue
        return nil
      end
    end
  end
end