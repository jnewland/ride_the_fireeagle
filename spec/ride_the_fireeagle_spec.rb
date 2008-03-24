require File.dirname(__FILE__) + '/spec_helper.rb'

describe "The plugin" do

  before(:each) do
    @user = User.create
  end

  it "should loads the fireeagle.yml config file" do
    User.fireeagle_config[:mobile_app_id].should == 1234
  end
  
  it "creates an instance method to access the config variables" do
    @user.fireeagle_config[:mobile_app_id].should == 1234
  end

  it "includes instances methods when calling ride_the_fireeagle" do
    @user.respond_to?(:location).should be_true
  end

end

describe "An new User" do

  before(:each) do
    @user = User.create
  end

  describe "should reflect authorization status" do

    it "negatively for final authorization" do
      @user.authorized_with_fireeagle?.should be_false
    end

    it "negatively for request token" do
      @user.has_request_token_from_fireeagle?.should be_false
    end

    it "by returning a nil authorization url" do
      @user.fireeagle_authorization_url.should be_nil
    end

    it "by returning false when attempting to authorize" do
      @user.authorize_with_fireeagle.should be_false
    end

  end

  describe "as a next step in authorization" do

    before(:each) do
      token = mock(OAuth::RequestToken)
      token.should_receive(:token).twice.and_return('token')
      token.should_receive(:secret).and_return('secret')
      client = FireEagle::Client.new(:consumer_key => 'key', :consumer_secret => 'sekret')
      client.should_receive(:get_request_token).and_return(token)
      @user.should_receive(:fireeagle).and_return(client)
    end

    it "should get and store a request token" do
      @user.get_fireeagle_request_token.should == 'token'
      @user.fireeagle_request_token.should == 'token'
      @user.fireeagle_request_token_secret.should == 'secret'
    end

  end

end

describe "An User with a request token" do

  before(:each) do
    @user = User.create(:fireeagle_request_token => 'token', :fireeagle_request_token_secret => 'secret')
  end

  describe "should reflect authorization status" do

    it "negatively for final authorization" do
      @user.authorized_with_fireeagle?.should be_false
    end

    it "positively for request token" do
      @user.has_request_token_from_fireeagle?.should be_true
    end

  end

  describe "as a next step in authorization" do

    before(:each) do
      @client = FireEagle::Client.new(:consumer_key => 'key', :consumer_secret => 'sekret', :request_token => 'token', :request_token_secret => 'secret')
      @user.should_receive(:fireeagle).and_return(@client)
    end

    it "returns an authorization url" do
      @user.fireeagle_authorization_url.should == "https://fireeagle.yahoo.net/oauth/authorize?oauth_token=token"
    end

    describe "should convert the request token to an access token" do

      before(:each) do
        access_token = mock(OAuth::AccessToken)
        access_token.should_receive(:token).and_return('access_token')
        access_token.should_receive(:secret).and_return('access_secret')
        @client.should_receive(:convert_to_access_token).and_return(access_token)
        @user.authorize_with_fireeagle.should
      end

      it "and clear the User's request token" do
        @user.fireeagle_request_token.should be_nil
        @user.fireeagle_request_token_secret.should be_nil
      end

      it "and set the User's access token" do
        @user.fireeagle_access_token.should == 'access_token'
        @user.fireeagle_access_token_secret.should == 'access_secret'
      end

    end

  end

end

describe "An authorized User" do

  before(:each) do
    @user = User.create(:fireeagle_access_token => 'foo', :fireeagle_access_token_secret => 'foo')
  end

  describe "should reflect authorization status" do

    it "positively for final authorization" do
      @user.authorized_with_fireeagle?.should be_true
    end

    it "negatively for request token" do
      @user.has_request_token_from_fireeagle?.should be_false
    end

  end

  describe "should be able to" do

    before(:each) do
      @client = FireEagle::Client.new(:consumer_key => 'key', :consumer_secret => 'sekret', :access_token => 'token', :access_token_secret => 'secret')
      @user.should_receive(:fireeagle).and_return(@client)
    end

    it "update it's location" do
      @response = mock(FireEagle::Response)
      @response.should_receive(:success?).and_return(true)
      @client.should_receive(:update).and_return(@response)
      @user.update_location(:q => 'foo').should be_true
    end

    it "query it's location" do
      @fe_user = mock(FireEagle::User)
      @location = mock(FireEagle::Location)
      @fe_user.should_receive(:best_guess).and_return(@location)
      @client.should_receive(:user).and_return(@fe_user)
      @user.location.should == @location
    end

  end

end