web: bundle exec rackup config.ru -p $PORT
worker:  bundle exec rake jobs:work
resque: env TERM_CHILD=1 bundle exec rake jobs:work
