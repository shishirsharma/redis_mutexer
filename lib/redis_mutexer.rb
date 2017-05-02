require "redis_mutexer/version"
require 'redis'

module RedisMutexer
  class Configuration
    attr_accessor :redis,
                  :host,
                  :port,
                  :db,
                  :default_expiry_time

    def initialize
      @host = 'localhost'         #host to run redis
      @port = '6379'              #port to run redis
      @db = 'redis_mutexer'       #redis database name
      @default_expiry_time = 60   #seconds
    end
  end

  class << self
    attr_accessor :config
  end

  def configure
    @config ||= Configuration.new
    yield(config) if block_given?
    # Create a redis connection if not provided with
    @config.redis ||=
      Redis.new(host: config.host,
                port: config.port,
                db: config.db
               )
    @config.logger ||= Logger.new(STDOUT)
    @config.logger.level = @config.log_level
  end

  def lock(user, obj, time)
    user.redis.setex("#{obj.class.name:obj.id}", time, obj.id)
  end

  def locked?(user, obj)
    user.get("#{obj.class.name:obj.id}").present?
  end

  def unlock(user, obj)
    user.redis.del("#{obj.class.name:obj.id}")
  end

  module_function :configure, :register_api_call, :api, :lock, :locked?, :unlock
end
