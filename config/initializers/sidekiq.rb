require 'sidekiq'
require 'sidekiq-scheduler'



Sidekiq.configure_server do |config|
  config.redis = { url: "redis://:REDACTED@ec2-23-20-19-160.compute-1.amazonaws.com:7599" }
end

Sidekiq.configure_client do |config|
    config.redis = { url: "redis://:REDACTED@ec2-23-20-19-160.compute-1.amazonaws.com:7599" }
end

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path('../../sidekiq_scheduler.yml', __FILE__))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end
