Gem::Specification.new do |s|
  s.name = %q{nuntium_api}
  s.version = "0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["InsTEDD"]
  s.date = %q{2011-06-10}
  s.description = %q{Access the Nuntium API in ruby. Nuntium is an open source and free platform -developed by InSTEDD- that allows applications to send and receive all type of messages. Examples of messages are sms, emails and twitter direct messages.}
  s.email = %q{aborenszweig@manas.com.ar}
  s.homepage = %q{http://code.google.com/p/nuntium-api-ruby}
  s.require_paths = ["lib"]
  s.files = [
    "lib/nuntium_api.rb",
    "lib/nuntium.rb"
  ]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Access the Nuntium API in ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
  end
end

