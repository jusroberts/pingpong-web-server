
desc "Auto-end any game that's been inactive for 20+ minutes"
task cleanup: :environment do
    time = Time.new
    Room.all.each do |room|
        next unless room.game
        if room.updated_at < time - 20.minutes
            puts "killing game after #{time - room.updated_at}"
            #game is just sitting, let's kill
            room.end_game(true)
            uri = URI.parse("http://pardot-pingpong.herokuapp.com/api/rooms/#{room.id}/end?code=#{room.client_token}")
            response = Net::HTTP.get_response(uri)
        end
    end
end
