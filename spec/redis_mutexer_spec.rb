require "spec_helper"

describe RedisMutexer do
  let (:user) { User.create!(id: 1, name: "pallav sharma")}
  let (:topic) { Topic.create!(id: 1, title: "this is test title")}

  it "has a version number" do
    expect(RedisMutexer::VERSION).not_to be nil
  end

  it "does something useful" do
    user.lock(topic, 60)
    user.locked?(topic)
    user.unlock(topic)
  end
end
