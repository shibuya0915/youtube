require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module YoutyubeTrendingApp
  class Application < Rails::Application
    config.load_defaults 7.2
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end 
  end
end
