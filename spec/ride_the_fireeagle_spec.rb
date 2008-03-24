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
    @user.respond_to?(:location).should == true
  end

end