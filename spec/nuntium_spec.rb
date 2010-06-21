require 'nuntium'

describe Nuntium do
  before :each do
    @api = Nuntium.new 'service_url', 'account_name', 'application_name', 'password'
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
end
