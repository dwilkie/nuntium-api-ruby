require 'rubygems'
require 'httparty'

class Nuntium
  include HTTParty
  
  def initialize(url, account, application, password)
    @url = url
    @account = account
    @application = application
    @auth = {:username => "#{account}/#{application}", :password => password}
  end
  
  def countries
    self.class.get "#{@url}/api/countries.json"
  end
  
  def country(iso)
    self.class.get "#{@url}/api/countries/#{iso}.json"
  end
  
  def carriers(country_id = nil)
    if country_id
      self.class.get "#{@url}/api/carriers.json", :query => {:country_id => country_id}
    else
      self.class.get "#{@url}/api/carriers.json"
    end
  end
  
  def carrier(guid)
    self.class.get "#{@url}/api/carriers/#{guid}.json"
  end
  
  def channels
    self.class.get "#{@url}/api/channels.json", :basic_auth => @auth
  end
  
  def create_channel(channel)
    self.class.post "#{@url}/api/channels.json", :basic_auth => @auth, :body => channel
  end
  
  def update_channel(channel)
    self.class.put "#{@url}/api/channels/#{channel['name']}.json", :basic_auth => @auth, :body => channel
  end
  
  def delete_channel(name)
    self.class.delete "#{@url}/api/channels/#{name}", :basic_auth => @auth
  end
  
  def candidate_channels_for_ao(message)
    self.class.get "#{@url}/api/candidate/channels.json", :basic_auth => @auth, :body => message
  end
  
  def send_ao(message)
    self.class.post "#{@url}/#{@account}/#{@application}/send_ao", :basic_auth => @auth, :body => message
  end
  
end
