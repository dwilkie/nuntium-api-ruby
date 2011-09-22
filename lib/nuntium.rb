# Provides access to the Nuntium Public API.
#
# === Install
#
#   gem install nuntium_api
#
# === Example
#
#   require 'rubygems'
#   require 'nuntium'
#
#   api = Nuntium.new "service_url", "account_name", "application_name", "application_password"
#
#   # Get all countries
#   countries = api.countries
#
#   # Get all carriers that belong to a specific country
#   carriers = api.carriers 'ar'
#
#   # Get all channels
#   channels = api.channels
#
#   # Create a channel
#   api.create_channel {
#     :name => "my_channel",
#     :kind => "clickatell",
#     :protocol => "sms",
#     :direction =>"bidirectional",
#     :enabled => true,
#     :priority => 10,
#     :configuration => {:password => "secret"}
#   }
#
#   message = {
#     :from => "sms://1234",
#     :to => "sms://5678",
#     :subject => "Hi",
#     :body => "Hello Nuntium!",
#   }
#
#   # Send an Application Originated message.
#   # The response is of type HTTParty::Response
#   response = api.send_ao message
#
#   # Can also send many messages at once
#   messages = [{:to => "sms://1", :body => 'One'}, {:to => "sms://2", :body => 'Two'}]
#   response = api.send_ao messages
#
#   # Simulate sending and get a list of candidate channels
#   api.get_candidate_channels_for_ao message

require 'rubygems'
require 'net/http'
require 'json'
require 'rest_client'
require 'cgi'
require File.expand_path('../nuntium/exception', __FILE__)

# Provides access to the Nuntium Public API.
class Nuntium
  # Creates an application-authenticated Nuntium api access.
  def initialize(url, account, application, password)
    @url = url
    @account = account
    @application = application
    @options = {
      :user => "#{account}/#{application}",
      :password => password,
      :headers => {:content_type => 'application/json'},
    }
  end

  # Gets the list of countries known to Nuntium as an array of hashes.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def countries
    get_json "/api/countries.json"
  end

  # Gets a country as a hash given its iso2 or iso3 code, or nil if a country with that iso does not exist.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def country(iso)
    get_json "/api/countries/#{iso}.json"
  end

  # Gets the list of carriers known to Nuntium that belong to a country as an array of hashes, given its
  # iso2 or iso3 code. Gets all carriers as an array of hashes if no country is specified.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def carriers(country_id = nil)
    if country_id
      get_json "/api/carriers.json?country_id=#{country_id}"
    else
      get_json "/api/carriers.json"
    end
  end

  # Gets a carrier as a hash given its guid, or nil if a carrier with that guid does not exist.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def carrier(guid)
    get_json "/api/carriers/#{guid}.json"
  end

  # Returns the list of channels belonging to the application or that don't
  # belong to any application, as an array of hashes.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def channels
    get "/api/channels.json" do |response, error|
      raise Nuntium::Exception.new error.message if error

      channels = JSON.parse response.body
      channels.each { |channel| read_configuration channel }
      channels
    end
  end

  # Returns a channel given its name. Raises when the channel does not exist.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def channel(name)
    get("/api/channels/#{name}.json") do |response, error|
      raise Nuntium::Exception.new error.message if error

      channel = JSON.parse response.body
      read_configuration channel
      channel
    end
  end

  # Creates a channel.
  #
  #   create_channel :name => 'foo', :kind => 'qst_server', :protocol => 'sms', :configuration => {:password => 'bar'}
  #
  # Raises Nuntium::Exception if something goes wrong. You can access specific errors on properties via the properties
  # accessor of the exception.
  def create_channel(channel)
    write_configuration channel
    post "/api/channels.json", channel.to_json do |response, error|
      handle_channel_error error if error

      channel = JSON.parse response
      read_configuration channel
      channel
    end
  end

  # Updates a channel.
  #
  #   update_channel :name => 'foo', :kind => 'qst_server', :protocol => 'sms', :configuration => {:password => 'bar'}
  #
  # Raises Nuntium::Exception if something goes wrong. You can access specific errors on properties via the properties
  # accessor of the exception.
  def update_channel(channel)
    write_configuration channel
    channel_name = channel['name'] || channel[:name]

    put "/api/channels/#{channel_name}.json", channel.to_json do |response, error|
      handle_channel_error error if error

      channel = JSON.parse response.body
      read_configuration channel
      channel
    end
  end

  # Deletes a chnanel given its name.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def delete_channel(name)
    delete "/api/channels/#{name}" do |response, error|
      raise Nuntium::Exception.new error.message if error

      response
    end
  end

  # Returns the list of candidate channels when simulating routing the given AO message.
  #
  #   candidate_channels_for_ao :from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'
  #
  # Raises Nuntium::Exception if something goes wrong.
  def candidate_channels_for_ao(message)
    get_channels "/api/candidate/channels.json?#{to_query message}"
  end

  # Sends one or many AO messages.
  # Returns an enhanced HTTParty::Response instance with id, guid and token readers that matches those x-headers
  # returned by Nuntium.
  #
  # To send a token, just include it in the message as :token => 'my_token'
  #
  #   send_ao :from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'
  #   send_ao [{:from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'}, {...}]
  #
  # Returns a hash with :id, :guid and :token keys if a single message was sent, otherwise
  # returns a hash with a :token key.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def send_ao(messages)
    if messages.is_a? Array
      post "/#{@account}/#{@application}/send_ao.json", messages.to_json do |response, error|
        raise Nuntium::Exception.new error.message if error

        {:token => response.headers[:x_nuntium_token]}
      end
    else
      get "/#{@account}/#{@application}/send_ao?#{to_query messages}" do |response, error|
        raise Nuntium::Exception.new error.message if error

        {
          :id => response.headers[:x_nuntium_id],
          :guid => response.headers[:x_nuntium_guid],
          :token => response.headers[:x_nuntium_token],
        }
      end
    end
  end

  # Gets AO messages that have the given token. The response is an array of hashes with the messages' attributes.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def get_ao(token)
    get_json "/#{@account}/#{@application}/get_ao.json?token=#{token}"
  end

  # Gets the custom attributes specified for a given address. Returns a hash with the attributes
  #
  # Raises Nuntium::Exception if something goes wrong.
  def get_custom_attributes(address)
    get_json "/api/custom_attributes?address=#{address}"
  end

  # Sets custom attributes of a given address.
  #
  # Raises Nuntium::Exception if something goes wrong.
  def set_custom_attributes(address, attributes)
    post "/api/custom_attributes?address=#{address}", attributes.to_json do |response, error|
      raise Nuntium::Exception.new error.message if error

      nil
    end
  end

  private

  def write_configuration(channel)
    return unless channel[:configuration] || channel['configuration']

    configuration = []
    (channel[:configuration] || channel['configuration']).each do |name, value|
      configuration << {:name => name, :value => value}
    end
    if channel[:configuration]
      channel[:configuration] = configuration
    else
      channel['configuration'] = configuration
    end
  end

  def read_configuration(channel)
    channel['configuration'] = Hash[channel['configuration'].map { |e| [e['name'], e['value']] }]
  end

  def get(path)
    resource = RestClient::Resource.new @url, @options
    resource = resource[path].get
    yield resource, nil
  rescue => ex
    yield nil, ex
  end

  def get_json(path)
    get(path) do |response, error|
      raise Nuntium::Exception.new error.message if error

      JSON.parse response.body
    end
  end

  def get_channels(path)
    get(path) do |response, error|
      raise Nuntium::Exception.new error.message if error

      channels = JSON.parse response.body
      channels.each { |channel| read_configuration channel }
      channels
    end
  end

  def post(path, data)
    resource = RestClient::Resource.new @url, @options
    resource = resource[path].post(data)
    yield resource, nil
  rescue  => ex
    yield nil, ex
  end

  def put(path, data)
    resource = RestClient::Resource.new @url, @options
    resource = resource[path].put(data)
    yield resource, nil
  rescue => ex
    yield nil, ex
  end

  def delete(path)
    resource = RestClient::Resource.new @url, @options
    resource = resource[path].delete
    yield resource, nil
  rescue => ex
    yield nil, ex
  end

  def handle_channel_error(error)
    if error.is_a? RestClient::BadRequest
      response = JSON.parse error.response.body
      raise Nuntium::Exception.new response['summary'], Hash[response['properties'].map {|e| [e.keys[0], e.values[0]]}]
    else
      raise Nuntium::Exception.new error.message
    end
  end

  def to_query(hash)
    query = ''
    first = true
    hash.each do |key, value|
      query << '&' unless first
      query << key.to_s
      query << '='
      query << CGI.escape(value.to_s)
      first = false
    end
    query
  end
end
