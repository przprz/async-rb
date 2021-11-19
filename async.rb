require "async"
require "async/http/internet"
require "redis"
require "sequel"

# prerequisites:
# * rvm use 3.0.1
# * bundle
# * set postgresql max_connections to 1000
# * bump max number of open file descriptors: ulimit -n 1000

DB = Sequel.connect('postgres://pawelprzeniczny@127.0.0.1:5432/cockpit_development', max_connections: 1000)
Sequel.extension(:fiber_concurrency)

N = 300 #

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

