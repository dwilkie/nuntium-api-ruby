require 'rubygems'
require 'httparty'

# Provides access to the Nuntium Public API.
class Nuntium
  include HTTParty
  
  # Creates an application-authenticated Nuntium api access.
  def initialize(url, account, application, password)
    @url = url
    @account = account
    @application = application
    @auth = {:username => "#{account}/#{application}", :password => password}
  end
  
  # Gets the list of countries known to Nuntium.
  def countries
    self.class.get "#{@url}/api/countries.json"
  end
  
  # Gets a country given its iso2 or iso3 code, or nil if a country with that iso does not exist.
  def country(iso)
    c = self.class.get "#{@url}/api/countries/#{iso}.json"
    c.strip.empty? ? nil : c
  end
  
  # Gets the list of carriers known to Nuntium that belong to a country, given its
  # iso2 or iso3 code.
  def carriers(country_id = nil)
    if country_id
      self.class.get "#{@url}/api/carriers.json", :query => {:country_id => country_id}
    else
      self.class.get "#{@url}/api/carriers.json"
    end
  end
  
  # Gets a carrier given its guid, or nil if a carrier with that guid does not exist.
  def carrier(guid)
    c = self.class.get "#{@url}/api/carriers/#{guid}.json"
    c.strip.empty? ? nil : c
  end
  
  # Returns the list of channels belonging to the application or that don't
  # belong to any application.
  def channels
    self.class.get "#{@url}/api/channels.json", :basic_auth => @auth
  end
  
  # Returns a chnanel given its name, or nil if the channel doesn't exist
  def channel(name)
    c = self.class.get "#{@url}/api/channels/#{name}.json", :basic_auth => @auth
    c.class <= String ? nil : c
  end
  
  # Creates a channel.
  # Example:
  #   create_channel :name => 'foo', :kind => 'qst_server', :protocol => 'sms',
  #     :configuration => [{:name => 'password', :value => 'bar'}]
  def create_channel(channel)
    self.class.post "#{@url}/api/channels.json", :basic_auth => @auth, :body => channel
  end
  
  # Creates a channel.
  # Example:
  #   update_channel :name => 'foo', :kind => 'qst_server', :protocol => 'sms',
  #     :configuration => [{:name => 'password', :value => 'bar'}]
  def update_channel(channel)
    self.class.put "#{@url}/api/channels/#{channel['name']}.json", :basic_auth => @auth, :body => channel
  end
  
  # Deletes a chnanel given its name.
  def delete_channel(name)
    self.class.delete "#{@url}/api/channels/#{name}", :basic_auth => @auth
  end
  
  # Returns the list of candidate channels when simulating routing the given
  # AO message.
  # Example:
  #   candidate_channels_for_ao :from => 'sms://1', :to => 'sms://2', 
  #     :subject => 'hello', :body => 'hi!'
  def candidate_channels_for_ao(message)
    self.class.get "#{@url}/api/candidate/channels.json", :basic_auth => @auth, :body => message
  end
  
  # Sends an AO message.
  # Example:
  #   send_ao :from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'
  def send_ao(message)
    self.class.post "#{@url}/#{@account}/#{@application}/send_ao", :basic_auth => @auth, :body => message
  end
  
end
