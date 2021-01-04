web: bundle exec puma -C config/heroku_puma.rb
worker: bundle exec rake jobs:work
guard: bundle exec guard
release: bundle exec rake db:migrate
