class Tentacle
  include Sidekiq::Worker

  # TODO: pull retort URL out into app config
  RETORT_BASE_URL = 'http://www.retort.us'

  # TODO: pull dactyl URL out into app config
  DACTYL_BASE_URL = 'http://www.dactyl.in'

  def perform
    startup
    scrape
    shutdown
  end

  private

  # Methods to override in tentacles

  def startup
  end

  def scrape
  end

  def respond_to id, message
  end

  def broadcast message
  end

  def shutdown
  end

  # Methods to use

  def log message, channel: 'log'
    # TODO: add real logging here
    puts "[#{channel}] #{message}"
    # TODO: add timestamps, etc
  end

  def feed_retort message:, identifier: nil, channel: nil, medium: nil
    log "Feeding \"#{message[0, 140]}\" to Retort, #{identifier}@#{medium}##{channel}"

    # TODO: clean all this garbage up
    id_params = ['']
    id_params << "identifier=#{identifier}" if identifier
    id_params << "channel=#{channel}"       if channel
    id_params << "medium=#{medium}"         if medium

    # TODO: repent for thy sins
    url = URI.escape([
        RETORT_BASE_URL,           # http://www.retort.us
        '/bigram/parse',           # /bigram/parse
        "?message=#{message}",     # ?message=Something someone said
        id_params.join('&')        # &channel=topsecret&medium=irc.nsa.gov
      ].join
    )

    Tentacle.get url
  rescue
    # TODO: include relevant data here
    log "Couldn't feed message to Retort: stuff", channel: 'error'
  end

  def sanitize message
    message
      .gsub(/<br[ ]?[\/]?>/, "\n") # Replace <br /> with \n
      .gsub(/<\/?[^>]*>/, ' ')     # Remove all HTML tags
      .gsub('&rsquo;', "'")
      .gsub('&lsquo;', "'")
      .gsub('&rdquo;', '"')
      .gsub('&ldquo;', '"')
      .gsub('&quot;',  '"')        # Replace &quot; with "
      .gsub('&#44;',   ',')        # Replace &#44; with ,
      .gsub('&#039;',  "'")        # Replace &#039; with '
      .gsub('&gt;',    '>')        # Replace &gt; with >
      .gsub('&lt;',    '<')        # Replace &lt; with <
      .gsub('“',       '"')        # etc
      .gsub('”',       '"')
      .gsub('…',       '...')
      .gsub('&#44;', ',')          # Replace &#44; with ,
      .gsub('&#039;', "'")         # Replace &#039; with '
      .strip
  rescue
    message
  end

  def self.get url
    # TODO: abstract this boilerplate out into RetortWorker with retries
    # TODO: whitelist uri.hosts here
    uri      = URI.parse(url)
    http     = Net::HTTP.new(uri.host, uri.port)
    request  = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    response.body
  end
end
