workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 1)

preload_app!

rackup DefaultRackup
env = ENV['RACK_ENV'] || 'development'
environment env

if env == 'development'
  port (ENV['PORT'] || 8080).to_i
else
  bind 'unix:///app/tmp/puma.sock'
end

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
