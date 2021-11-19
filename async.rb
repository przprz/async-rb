# taken from https://brunosutic.com/blog/async-ruby#

require "async"
require "async/http/internet"
require "redis"
require "sequel"

db_user = ARGV[0] || 'pawelprzeniczny'
db_name = ARGV[1] || 'cockpit_development'

DB = Sequel.connect("postgres://#{db_user}@127.0.0.1:5432/#{db_name}", max_connections: 1000)
Sequel.extension(:fiber_concurrency)

N = 300 # TODO: try higher values

# Warming up redis clients
redis_clients = 1.upto(N).map { Redis.new.tap(&:ping) }

start = Time.now

Async do |task|
  http_client = Async::HTTP::Internet.new

  N.times do |i|
    task.async do
      http_client.get("https://httpbin.org/delay/1.6")
    end

    task.async do
      redis_clients[i].blpop("abc123", 2)
    end

    task.async do
      DB.run("SELECT pg_sleep(2)")
    end

    task.async do
      sleep 2
    end

    task.async do
      `sleep 2`
    end
  end
end

puts "Duration: #{Time.now - start}s"

