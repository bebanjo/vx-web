source 'https://rubygems.org'

gem 'rails', '4.0.10'
gem 'pg'

gem 'haml-rails'
gem 'omniauth-github'
gem 'puma'
gem 'state_machine'
gem 'active_model_serializers'
gem 'carrierwave'
gem 'sshkey'

# vx-builder dependencies
gem 'vx-lib-message',           :github => 'bebanjo/vx-message'
gem 'vx-common',            :github => 'bebanjo/vx-common', :branch => 'bebanjo'

gem 'vx-builder',           :github => 'bebanjo/vx-builder',           :branch => 'bebanjo'
gem 'vx-service_connector', :github => 'bebanjo/vx-service_connector', :branch => 'bebanjo'
gem 'vx-consumer',          :github => 'bebanjo/vx-consumer'
gem 'vx-instrumentation',   :github => 'bebanjo/vx-instrumentation', :tag => 'v0.1.4'
gem 'vx-common-spawn',      :github => 'bebanjo/vx-common-spawn'
gem 'vx-common-rack-builder', :github => 'bebanjo/vx-common-rack-builder'

gem 'dalli'
gem 'dotenv'
gem 'braintree'

group :assets do
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
end

group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rspec-its', :require => false
  gem 'factory_girl_rails'
end

group :test do
  gem 'rr'
  gem 'webmock'
  gem 'timecop'
  gem 'nokogiri'
end

group :development do
  gem 'annotate'
  gem 'foreman'
end
