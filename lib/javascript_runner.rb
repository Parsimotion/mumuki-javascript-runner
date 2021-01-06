require 'mumukit'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

Mumukit.runner_name = 'javascript'
Mumukit.configure do |config|
  config.docker_image = ENV['JAVASCRIPT_WORKER_VERSION'] || 'productecadev/mumuki-mocha-worker-node12:1.0'
  config.structured = true
  config.stateful = true
  config.content_type = 'markdown'
  config.command_time_limit = 6
end

require_relative './version'
require_relative './metadata_hook'
require_relative './validation_hook'
require_relative './test_hook'
require_relative './expectations_hook'
require_relative './feedback_hook'
require_relative './query_hook'
require_relative './try_hook'
