require "redis_mutexer/version"
require "redis"

module RedisMutexer

  def redis
    redis ||=
      Redis.new(:host => "localhost",
                :port => "6379",
                :db => 1
               )
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

  module_function :redis
end
