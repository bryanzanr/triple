require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a name" do
    expect(User.new(name: "Alice")).to be_valid
  end

  it "is invalid without a name" do
    expect(User.new(name: nil)).not_to be_valid
  end

  it "can follow and unfollow another user" do
    alice = User.create!(name: "Alice")
    bob   = User.create!(name: "Bob")

    alice.following << bob
    expect(alice.following).to include(bob)
    expect(bob.followers).to include(alice)

    alice.active_follows.where(followed: bob).destroy_all
    expect(alice.following).not_to include(bob)
  end
end
