require 'rails_helper'

RSpec.describe Follow, type: :model do
  it "prevents self-follow" do
    alice = User.create!(name: "Alice")
    follow = Follow.new(follower: alice, followed: alice)
    expect(follow).not_to be_valid
    expect(follow.errors[:base]).to include("cannot follow yourself")
  end

  it "enforces uniqueness of follower/followed pair" do
    alice = User.create!(name: "Alice")
    bob   = User.create!(name: "Bob")
    Follow.create!(follower: alice, followed: bob)

    dup = Follow.new(follower: alice, followed: bob)
    expect(dup).not_to be_valid
  end
end
