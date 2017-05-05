require "redis_mutexer/version"
require "redis"

module RedisMutexer
  # class Configuration
  #   attr_accessor :host,
  #                 :port,
  #                 :db,
  #                 :default_expiry_time

  #   def initialize
  #     @host = 'localhost'             #host to run redis
  #     @port = '6379'                  #port to run redis
  #     @db = 'redis_mutexer'           #redis database name
  #     @default_expiry_time = 60 * 5   #seconds
  #   end
  # end

  # class << self
  #   attr_accessor :config
  # end
  
  def redis
    redis ||=
      Redis.new(:host => "localhost",
                :port => "6379",
                :db => 1
               )
  end

  # def configure
  #   @config ||= Configuration.new
  #   yield(config) if block_given?
  #   # Create a redis connection if not provided with
  #   @config.redis ||=
  #     Redis.new(host: config.host,
  #               port: config.port,
  #               db: config.db
  #              )
  # end

  class User
    attr_accessor :id, :name, :city
    include RedisMutexer

    def lock(obj, time)
      redis.setex("#{obj.class.name + ":" + obj.id.to_s}", time, self.id)
    end
    def locked?(obj)
      (redis.get("#{obj.class.name + ":" + obj.id.to_s}").to_i == self.id) ? true : false
    end
    def unlock(obj)
      redis.del("#{obj.class.name + ":" + obj.id.to_s}")
    end

  end

  def raise_assertion_error
    raise AssertionError, 'block syntax has been removed from #lock, use #with_lock instead'
  end

  module_function :redis
end
