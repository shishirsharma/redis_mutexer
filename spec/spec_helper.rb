require "bundler/setup"
require "redis_mutexer"

require 'rubygems'
require 'active_record'
require 'rspec'
require 'pry'
require "generator_spec"

require 'logger'


PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')
Dir[File.join(PROJECT_ROOT, 'spec/support/**/*.rb')].each { |file| require(file) }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) { setup_db }
  config.after(:all)  { teardown_db }
end


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

logger = Logger.new(STDOUT)
logger.info ">>1 using google_geocoding_api"

def setup_db
  logger = Logger.new(STDOUT)
  logger.info "Setup DB"

  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string   :name
      t.timestamps
    end

    create_table :topics do |t|
      t.string   :title
      t.timestamps
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class User < ActiveRecord::Base
  include RedisMutexer
end

class Topic < ActiveRecord::Base
end
