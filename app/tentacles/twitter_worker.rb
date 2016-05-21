class TwitterWorker < Tentacle
  attr_reader :client

  def startup
    # TODO: move config into db
    # TODO: make account used configurable from params
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def scrape
    tweets = @client.home_timeline
    tweets.each do |tweet|
      log "Logging @#{tweet.user.screen_name}: #{tweet.text}"
      feed_retort(
        message:    tweet.text,
        medium:     'twitter',
        identifier: tweet.user.screen_name
      )
    end
  end

  # respond_to('drusepth', 'yo dog') => tweet '@drusepth yo dog'
  def respond_to id, message
    broadcast "@#{id} #{message}"
  end

  # Tweet
  def broadcast message
    @client.update message
  #rescue
  #  log "Couldn't tweet: info", channel: 'error'
  end

  def shutdown
    # TODO: not sure if this is needed
    @client = nil
  end

end