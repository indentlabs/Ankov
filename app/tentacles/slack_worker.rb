class SlackWorker < Tentacle
  attr_reader :client

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
end