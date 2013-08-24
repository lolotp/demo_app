web: bundle exec rackup config.ru -p $PORT
scheduler: bundle exec rake resque:scheduler
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake environment resque:work
