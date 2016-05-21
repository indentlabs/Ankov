class RedditWorker < Tentacle
  attr_reader :client

  def startup
    # TODO: move config into db
    # TODO: make account used configurable from params
    @client = Redd.it(
      :script,
      "H3o8S_X6B0WYzg",
      "VKhDeFb95MNkusqz539h9XcoNfk",
      "not_gabe_2", "not_gabe_2",
      user_agent: "Abe Newman v1.0.0 by /u/ghost_of_drusepth"
      )
    client.authorize!
  end

  def scrape
    begin
      stream_all
    rescue Redd::Error::RateLimited => error
      sleep(error.time)
      retry
    rescue Redd::Error => error
      # 5-something errors are usually errors on reddit's end.
      raise error unless (500...600).include?(error.code)
      retry
    rescue
      log "Failed to scrape reddit", "error"
    end
  end

  def respond_to id, message
    # TODO: Respond to comment ID with message
  end

  def broadcast message
    # TODO: Figure out how to include params/subreddit here in polymorphic way
  end

  def shutdown
    # TODO: not sure if this is needed
    @client = nil
  end

  private

  def stream_all
    client.stream :get_comments, "all" do |comment|
      feed_retort(
        message:    comment.body,
        identifier: "/u/#{comment.author}",
        channel:    comment.subreddit,
        medium:     'reddit'
        )
    end
  end
end