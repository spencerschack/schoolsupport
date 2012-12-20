web: bundle exec unicorn -p $PORT -E $RACK_ENV -c ./config/unicorn.rb
worker: QUEUE=* bundle exec rake environment resque:work