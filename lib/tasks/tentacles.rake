desc "Spin up reddit tentacle"
task :reddit_tentacle => :environment do
  # TODO: Add reasonable output here
  # TODO: Handle per-run auth/config here
  RedditWorker.new.perform
end

desc "Spin up tumblr tentacle"
task :tumblr_tentacle => :environment do
  TumblrWorker.new.perform
end

desc "Spin up twitter tentacle"
task :twitter_tentacle => :environment do
  TwitterWorker.new.perform
end