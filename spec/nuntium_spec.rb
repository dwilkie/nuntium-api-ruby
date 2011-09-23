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

  it "gets channel" do
    should_receive_http_get '/api/channels/Argentina.json', %({"name": "Argentina", "configuration": [{"name": "foo", "value": "bar"}]})

    api.channel('Argentina').should eq({'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}})
  end

  it "creates channel" do
    channel_json = %({"name":"Argentina","configuration":[{"value":"bar","name":"foo"}]})
    should_receive_http_post '/api/channels.json', channel_json, channel_json

    channel = {'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}

    api.create_channel(channel).should eq(channel)
  end

  it "updates channel", :focus => true do
    channel_json = %({"name":"Argentina","configuration":[{"value":"bar","name":"foo"}]})
    should_receive_http_put '/api/channels/Argentina.json', channel_json, channel_json

    channel = {'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}

    api.update_channel(channel).should eq(channel)
  end

  it "deletes channel", :focus => true do
    should_receive_http_delete '/api/channels/Argentina'

    api.delete_channel('Argentina')
  end

  it "gets candidate channels for ao", :focus => true do
    should_receive_http_get "/api/candidate/channels.json?from=#{CGI.escape 'sms://1234'}&body=Hello", %([{"name":"Argentina","configuration":[{"value":"bar","name":"foo"}]}])

    channels = api.candidate_channels_for_ao :from => 'sms://1234', :body => 'Hello'
    channels.should eq([{'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}])
  end

  it "sends single ao" do
    should_receive_http_get_with_headers "/account/application/send_ao?from=#{CGI.escape 'sms://1234'}&body=Hello", :x_nuntium_id => '1', :x_nuntium_guid => '2', :x_nuntium_token => '3'
    response = api.send_ao :from => 'sms://1234', :body => 'Hello'
    response.should eq(:id => '1', :guid => '2', :token => '3')
  end

  it "sends many aos" do
    post_body = %([{"from":"sms://1234","body":"Hello"}])
    should_receive_http_post_with_headers "/account/application/send_ao.json", post_body, :x_nuntium_token => '3'
    response = api.send_ao [{:from => 'sms://1234', :body => 'Hello'}]
    response.should eq(:token => '3')
  end

  it "gets ao" do
    should_receive_http_get '/account/application/get_ao.json?token=foo', %([{"name": "Argentina", "iso2": "ar"}])

    api.get_ao('foo').should eq([{'name' => 'Argentina', 'iso2' => 'ar'}])
  end

  it "gets custom attributes" do
    should_receive_http_get '/api/custom_attributes?address=foo', %([{"name": "Argentina", "iso2": "ar"}])

    api.get_custom_attributes('foo').should eq([{'name' => 'Argentina', 'iso2' => 'ar'}])
  end

  it "sets custom attributes" do
    should_receive_http_post '/api/custom_attributes?address=foo', %({"application":"bar"}), ''

    api.set_custom_attributes('foo', :application => :bar)
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

  def should_receive_http_get_with_headers(path, headers)
    resource = mock 'resource'
    RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

    resource2 = mock 'resource2'
    resource.should_receive(:[]).with(path).and_return(resource2)

    resource3 = mock 'resource3'
    resource2.should_receive(:get).and_return(resource3)

    resource3.stub(:headers) { headers }
  end

  def should_receive_http_post(path, data, body)
    resource = mock 'resource'
    RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

    resource2 = mock 'resource2'
    resource.should_receive(:[]).with(path).and_return(resource2)

    resource3 = mock 'resource3'
    resource2.should_receive(:post).with(data).and_return(resource3)

    resource3.stub(:body) { body }
  end

  def should_receive_http_post_with_headers(path, data, headers)
    resource = mock 'resource'
    RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

    resource2 = mock 'resource2'
    resource.should_receive(:[]).with(path).and_return(resource2)

    resource3 = mock 'resource3'
    resource2.should_receive(:post).with(data).and_return(resource3)

    resource3.stub(:headers) { headers }
  end

  def should_receive_http_put(path, data, body)
    resource = mock 'resource'
    RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

    resource2 = mock 'resource2'
    resource.should_receive(:[]).with(path).and_return(resource2)

    resource3 = mock 'resource3'
    resource2.should_receive(:put).with(data).and_return(resource3)

    resource3.should_receive(:body).and_return(body)
  end

  def should_receive_http_delete(path)
    resource = mock 'resource'
    RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

    resource2 = mock 'resource2'
    resource.should_receive(:[]).with(path).and_return(resource2)

    resource3 = mock 'resource3'
    resource2.should_receive(:delete)
  end
end
