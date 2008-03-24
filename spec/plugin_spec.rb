require File.dirname(__FILE__) + '/spec_helper.rb'
 
describe "The plugin" do
 
  before(:each) do
    @user = User.create
  end
 
  describe "includes instances methods when calling ride_the_fireeagle" do
    @user.respond_to?(:location).should == true
  end
  
end