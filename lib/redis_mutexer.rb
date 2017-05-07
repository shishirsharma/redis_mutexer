require "redis_mutexer/version"
require "redis"

module RedisMutexer
  class Configuration
    attr_accessor :redis, :host, :port, :db, :time, :logger

    def initialize
      @host = 'localhost'    #host
      @port = 6379           #port
      @db = 'redis_mutexer'  #database namespace
      @time = 60             #seconds
    end
  end

  class << self
    attr_accessor :config
  end

  def redis
    @config ||= Configuration.new
    @config.redis ||=
      Redis.new(host: config.host,
                port: config.port,
                db:   config.db,
                time: config.time
               )
  end

  def configure
    @config ||= Configuration.new
    yield(config) if block_given?

    # Create a redis connection if not provided with
    @config.redis ||=
      Redis.new(host: config.host,
                port: config.port,
                db:   config.db,
                time: config.time
               )
    @config.logger ||= Logger.new(STDOUT)
  end

  def lock(obj, time)
    redis.setex("#{obj.class.name + ":" + obj.id.to_s}", time, self.id)
  end
  def locked?(obj)
    (redis.get("#{obj.class.name + ":" + obj.id.to_s}").to_i == self.id) ? true : false
  end
  def unlock(obj)
    redis.del("#{obj.class.name + ":" + obj.id.to_s}")
  end

  module_function :configure
end
