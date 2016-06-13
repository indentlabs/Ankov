class FortuneWorker < Tentacle
  attr_reader :client

  # TODO: make this configurable per worker instance
  BOARDS_TO_SCRAPE = %w(
    3 a aco adv an asp b biz c cgl ck co d diy e fa fit g gd
    h his i ic int jp k lgbt lit m mlp mu n news o out p po
    pol qst r r9k s s4s sci soc sp tg toy trv tv u v vp vg vr
    wsg wsr x y
  )

  def startup
    puts "TEST"
  end

  def scrape
    BOARDS_TO_SCRAPE.shuffle.each do |board|
      log "Scraping board /#{board}/", channel: "info"

      threads_for_board(board).each do |thread|
        log "\tFetching thread #{thread.thread}", channel: "verbose"

        comments_for_thread(board, thread.thread).each do |comment|
          log "\t\tParsing comment #{sanitize comment.com}", channel: "verbose"

          feed_retort(
            message:    sanitize(comment.com),
            medium:     '4chan',
            channel:    board
          )
        end
      end
    end
  end

  # Respond to thread with id
  def respond_to id, message
  end

  # Post new thread
  def broadcast message
  end

  def shutdown
  end

  private

  def threads_for_board board
    Fourchan::Board.new(board).threads
  end

  def comments_for_thread board, threadid
    Fourchan::Post.new(board, threadid).all
  end

end
