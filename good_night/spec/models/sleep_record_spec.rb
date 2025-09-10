require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { User.create!(name: "Alice") }

  it "is valid with started_at" do
    record = SleepRecord.new(user: user, started_at: Time.current)
    expect(record).to be_valid
  end

  it "is invalid without started_at" do
    record = SleepRecord.new(user: user)
    expect(record).not_to be_valid
  end

  it "computes duration when ended_at is set" do
    start_time = Time.current
    end_time   = start_time + 8.hours
    record = SleepRecord.create!(user: user, started_at: start_time, ended_at: end_time)
    expect(record.duration_sec).to eq 8.hours.to_i
  end

  it "rejects ended_at earlier than started_at" do
    record = SleepRecord.new(user: user, started_at: Time.current, ended_at: 1.hour.ago)
    expect(record).not_to be_valid
  end
end
