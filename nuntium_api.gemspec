Gem::Specification.new do |s|
  s.name = %q{nuntium_api}
  s.version = "0.21"
  s.platform    = Gem::Platform::RUBY
  s.authors = ["InsTEDD"]
  s.email = "aborenszweig@manas.com.ar"
  s.summary = "Access the Nuntium API in ruby"
  s.description = "Access the Nuntium API in ruby. Nuntium is an open source and free platform -developed by InSTEDD- that allows applications to send and receive all type of messages. Examples of messages are sms, emails and twitter direct messages."
  s.homepage = "https://bitbucket.org/instedd/nuntium-api-ruby/src"
  s.files = [
    "lib/nuntium_api.rb",
    "lib/nuntium.rb",
    "lib/nuntium/exception.rb",
  ]
  s.require_path = "lib"

  s.rdoc_options = %w{--charset=UTF-8}
  s.extra_rdoc_files = %w{README.md}

  s.add_dependency "rest-client"
  s.add_dependency "json"

  s.add_development_dependency "rspec"
end
