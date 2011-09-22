require(File.expand_path("../../lib/nuntium",  __FILE__))

describe Nuntium do
  let(:url) { "http://example.com" }
  let(:options) { {:user => "account/application", :password => "password", :headers => {:content_type => 'application/json'}} }
  let(:api) { Nuntium.new url, "account", "application", "password" }

  it "gets countries" do
    should_receive_http_get '/api/countries.json', %([{"name": "Argentina", "iso2": "ar"}])

    api.countries.should eq(['name' => 'Argentina', 'iso2' => 'ar'])
  end

  it "gets country" do
    should_receive_http_get '/api/countries/ar.json', %({"name": "Argentina", "iso2": "ar"})

    api.country('ar').should eq({'name' => 'Argentina', 'iso2' => 'ar'})
  end

  it "gets carriers" do
    should_receive_http_get '/api/carriers.json', %([{"name": "Argentina", "iso2": "ar"}])

    api.carriers.should eq(['name' => 'Argentina', 'iso2' => 'ar'])
  end

  it "gets carriers for a country" do
    should_receive_http_get '/api/carriers.json?country_id=ar', %([{"name": "Argentina", "iso2": "ar"}])

    api.carriers('ar').should eq(['name' => 'Argentina', 'iso2' => 'ar'])
  end

  it "gets carrier" do
    should_receive_http_get '/api/carriers/ar.json', %({"name": "Argentina", "iso2": "ar"})

    api.carrier('ar').should eq({'name' => 'Argentina', 'iso2' => 'ar'})
  end

  it "gets channels" do
    should_receive_http_get '/api/channels.json', %([{"name": "Argentina", "configuration": [{"name": "foo", "value": "bar"}]}])

    api.channels.should eq([{'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}])
  end

  it "gets channel", :focus => true do
    should_receive_http_get '/api/channels/Argentina.json', %({"name": "Argentina", "configuration": [{"name": "foo", "value": "bar"}]})

    api.channel('Argentina').should eq({'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}})
  end

  def should_receive_http_get(path, body)
    resource = mock 'resource'
    RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

    resource2 = mock 'resource2'
    resource.should_receive(:[]).with(path).and_return(resource2)

    resource3 = mock 'resource3'
    resource2.should_receive(:get).and_return(resource3)

    resource3.should_receive(:body).and_return(body)
  end
end
