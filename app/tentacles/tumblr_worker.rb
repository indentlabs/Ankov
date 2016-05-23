class TumblrWorker < Tentacle
  attr_reader :client

  def startup
    # TODO: move config into db
    # TODO: make account used configurable from params
    Tumblr.configure do |config|
      config.consumer_key       = "R8dfrUYX2HesfwTXZGYNGz2aJcI0aV0VVEkIm25vBmUxxX3Q7R"
      config.consumer_secret    = "zTKtMhMrCbkBTBJJEZPy0RtFJicgUNv84n4UxuTOtpR1DGC8F7"
      config.oauth_token        = "UYWPx7w6DRR5ga7zyVKXKj4ws5wQERTOunutAX9Nq7gpsNAD0j"
      config.oauth_token_secret = "a2ODh44u26v6zf8nOEJpQ5TTEkIx4DkXkamVf8GJoM1GKKPWqE"
    end

    @client = Tumblr::Client.new
  end

  def scrape
    @client.dashboard["posts"].each do |post|
      text = sanitize(post['body'] || post['caption'])
      next unless text && text.length > 0

      log "Scraping #{post['blog_name']}'s text of length #{text.length}: #{text[0, 140]}"

      feed_retort(
        message: text,
        channel: post['blog_name'],
        medium:  'tumblr'
      )
    end
  end

  def respond_to id, message
    # TODO: Respond to comment ID with message
  end

  def broadcast message, blog: nil
    # TODO: handle other post types
    # TODO: figure out how to polymorphically include options here (post type, etc)

    blog ||= 'ankov-me.tumblr.com'

    if message.length < 100
      # TODO: handle source?
      client.quote(blog, { quote: message, source: 'Anonymous' })
    else
      # TODO: handle title?
      @client.text(blog, { title: message })
    end

  end

  def shutdown
    # TODO: not sure if this is needed
    @client = nil
  end

end