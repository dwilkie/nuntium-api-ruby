require 'nuntium'

describe Nuntium do
  before :each do
    @api = Nuntium.new 'service_url', 'account_name', 'application_name', 'password'
    @auth = {:basic_auth => {:username => "account_name/application_name", :password => "password" }}
  end

  it "gets countries" do
    Nuntium.should_receive('get').with('service_url/api/countries.json')
    @api.countries
  end

  it "gets a country" do
    Nuntium.should_receive('get').with('service_url/api/countries/ar.json')
    @api.country 'ar'
  end

  it "gets carriers" do
    Nuntium.should_receive('get').with('service_url/api/carriers.json')
    @api.carriers
  end

  it "gets country's carriers" do
    Nuntium.should_receive('get').with('service_url/api/carriers.json', {:query => {:country_id => 'ar'}})
    @api.carriers 'ar'
  end

  it "gets user custom attributes" do
    Nuntium.should_receive('get').with('service_url/api/custom_attributes?address=sms://foo', @auth).and_return(:foo => 123)
    @api.get_custom_attributes('sms://foo').should == {:foo => 123}
  end

  it "return nil if no custom attributes" do
    Nuntium.should_receive('get').with('service_url/api/custom_attributes?address=sms://foo', @auth).and_return(" ")
    @api.get_custom_attributes('sms://foo').should == nil
  end

  it "sets user custom attributes" do
    Nuntium.should_receive('post').with('service_url/api/custom_attributes?address=sms://foo', @auth.merge(:body => {:bar => 123}))
    @api.set_custom_attributes 'sms://foo', {:bar => 123}
  end

end
