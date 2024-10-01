Gem::Specification.new do |s|
  s.name = "interception"
  s.version = "0.5"
  s.license = "MIT"
  s.author = "Conrad Irwin"
  s.email = "conrad.irwin@gmail.com"
  s.homepage = "http://github.com/ConradIrwin/interception"
  s.summary = "Intercept exceptions as they are being raised"
  s.description = "Provides a cross-platform ability to intercept all exceptions as they are raised."
  s.required_ruby_version = ">= 1.8"  # Even though 1.9 is only tested

  s.files = `git ls-files -z`.split("\x0")
  s.extensions = "ext/extconf.rb"
  s.require_path = "lib"

  # Rake DOES NOT SUPPORT <1.9.3
  s.add_development_dependency 'rake', '>= 12.2'
  s.add_development_dependency 'rspec', '~> 3.4'
end
