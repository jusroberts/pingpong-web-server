# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if Rails.env == "development"
    10.times do 
        Player.new(
            name: Faker::Internet.username,
            rfid_hash: Faker::Crypto.md5,
            rating_skill: Faker::Number.number(1),
            rating_deviation: Faker::Number.number(1),
            image_url: Faker::Avatar.image,
            pin: "1"#Faker::Number.number(6).to_s,
        ).save
    end

    Room.new(
        client_token: "dev",
        name: "dev",
        created_at: Time.now,
        team_a_score: 0,
        team_b_score: 0,
        game: false
    ).save
end