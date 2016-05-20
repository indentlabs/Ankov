desc "Spin up reddit tentacle"
task :reddit_tentacle => :environment do
  puts "Starting reddit tentacle"
  # TODO: Handle per-run auth/config here
  RedditWorker.new.perform
  puts "Reddit is done"
end