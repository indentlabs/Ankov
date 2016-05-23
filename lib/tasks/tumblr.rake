desc "Post something to Tumblr Ankov blog"
task :tumblr_broadcast => :environment do
  # TODO: abstract this out for broadcasting over any medium
  # TODO: allow posting from other users
  # TODO: allow passing in a message
  generator_url = "#{Tentacle::RETORT_BASE_URL}/markov/create?medium=quran"
  message = Tentacle.get(generator_url)

  puts "Broadcasting: #{message}"

  # TODO: expose some method that wraps a yield with startup/shutdown so this isn't needed
  TumblrWorker.new.tap do |t|
    t.startup
    t.broadcast message
    t.shutdown
  end
end

desc "Post something to Tumblr Jumblr blog"
task :tumblr_tia => :environment do
  # TODO: abstract this out for broadcasting over any medium
  # TODO: allow posting from other users
  # TODO: allow passing in a message
  generator_url = "#{Tentacle::RETORT_BASE_URL}/markov/create?medium=reddit&channel=/r/TumblrInAction"
  message = Tentacle.get(generator_url)

  puts "Broadcasting: #{message}"

  # TODO: expose some method that wraps a yield with startup/shutdown so this isn't needed
  TumblrWorker.new.tap do |t|
    t.startup
    t.broadcast(message, blog: 'ankov-jumblr.tumblr.com')
    t.shutdown
  end
end
