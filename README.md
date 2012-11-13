# nuntium-api-ruby

Access the Nuntium API in Ruby.

## Install

    gem install nuntium_api

## Gemfile

    gem 'nuntium_api'

## Example

    require 'rubygems'
    require 'nuntium'

    api = Nuntium.new "service_url", "account_name", "application_name", "application_password"

    message = {
      :from => "sms://1234",
      :to => "sms://5678",
      :body => "Hello Nuntium!",
    }

    # Send an Application Originated message.
    response = api.send_ao message

    # Can also send many messages at once
    messages = [{:to => "sms://1", :body => 'One'}, {:to => "sms://2", :body => 'Two'}]
    response = api.send_ao messages

    # Simulate sending and get a list of candidate channels
    api.get_candidate_channels_for_ao message

    # Get all countries
    countries = api.countries

    # Get all carriers that belong to a specific country
    carriers = api.carriers countries[0].iso2

    # Get all channels
    channels = api.channels

    # Create a channel
    api.create_channel {
      :name => "my_channel",
      :kind => "clickatell",
      :protocol => "sms",
      :direction =>"bidirectional",
      :enabled => true,
      :priority => 10,
      :configuration => {:password => "secret"}
    }
