class RedditWorker < Tentacle
  attr_reader :reddit

  def startup
    # TODO: move config into db
    # TODO: make account used configurable from params
    @reddit = Redd.it(
      :script,
      "H3o8S_X6B0WYzg",
      "VKhDeFb95MNkusqz539h9XcoNfk",
      "not_gabe_2", "not_gabe_2",
      user_agent: "Abe Newman v1.0.0 by /u/ghost_of_drusepth"
      )
    reddit.authorize!
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

  def shutdown
    @reddit = nil
  end

  private

  def stream_all
    reddit.stream :get_comments, "all" do |comment|
      feed_retort(
        comment.body,
        identifier: "/u/#{comment.author}",
        channel: comment.subreddit,
        medium: 'reddit'
        )
    end
  end
end