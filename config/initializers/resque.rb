ENV["REDISTOGO_URL"] ||= "redis://localhost:6379/"

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS_WORKER = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis = REDIS_WORKER
