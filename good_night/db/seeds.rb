# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

Follow.delete_all
SleepRecord.delete_all
User.delete_all

# Create sample users
alice   = User.create!(name: "Alice")
bob     = User.create!(name: "Bob")
charlie = User.create!(name: "Charlie")

# Alice follows Bob and Charlie
Follow.create!(follower: alice, followed: bob)
Follow.create!(follower: alice, followed: charlie)

# Helper to place times in the previous calendar week
Time.use_zone("Asia/Jakarta") do
  now = Time.zone.now
  start_of_this_week = now.beginning_of_week(:monday)
  start_of_prev_week = start_of_this_week - 1.week

  # Example: Bob slept 7 hours last week
  SleepRecord.create!(
    user: bob,
    started_at: start_of_prev_week + 1.day + 22.hours, # Monday 22:00
    ended_at: start_of_prev_week + 2.days + 5.hours    # Tuesday 05:00
  )

  # Example: Charlie slept 6 hours last week
  SleepRecord.create!(
    user: charlie,
    started_at: start_of_prev_week + 3.days + 23.hours, # Thursday 23:00
    ended_at: start_of_prev_week + 4.days + 5.hours     # Friday 05:00
  )
end

puts "Users:"
User.all.each { |u| puts "- id=#{u.id}, name=#{u.name}" }
