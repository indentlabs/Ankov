desc "Tweet something from a twitter tentacle"
task :twitter_broadcast => :environment do
  # TODO: allow tweeting from other users
  # TODO: allow passing in a message to tweet
  tweet_generator_url = "#{Tentacle::RETORT_BASE_URL}/markov/create?medium=twitter"
  tweet = Tentacle.get(tweet_generator_url)

  # TODO: expose some method that wraps a yield with startup/shutdown so this isn't needed
  twitter = TwitterWorker.new.tap do |t|
    t.startup
    t.broadcast tweet
    t.shutdown
  end
end
