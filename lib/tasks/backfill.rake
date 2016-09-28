namespace :backfill do
  desc 'Data backfill tasks'
  task backfill_rating: :environment do
    player_cache = {}
    manager = RatingManager.new

    loop do
      # Grab a chunk of game_ids
      game_ids = GameHistory
                     .limit(100)
                     .order('game_id asc')
                     .pluck('DISTINCT game_id')

      break if game_ids.length == 0

      # Iterate over game_ids and process each one
      game_ids.each do |game_id|
        puts "Processing game id #{game_id}..."
        # @param [Array<GameHistory>] game_records
        game_records = GameHistory.where(:game_id => game_id)

        winner_ids = []
        loser_ids = []

        winning_margin = nil
        losing_margin = nil

        game_records.each do |game_record|
          # @type game_record [GameHistory]

          if game_record.win
            winner_ids << game_record.player_id
            winning_margin = game_record.player_team_score - game_record.opponent_team_score
          else
            loser_ids << game_record.player_id
            losing_margin = game_record.player_team_score - game_record.opponent_team_score
          end
        end

        winning_players = winner_ids.map do |winner_id|
          unless player_cache.has_key?(winner_id)
            player_cache[winner_id] = Player.find_by(:id => winner_id)
          end
          player_cache[winner_id]
        end
        losing_players = loser_ids.map do |loser_id|
          unless player_cache.has_key?(loser_id)
            player_cache[loser_id] = Player.find_by(:id => loser_id)
          end
          player_cache[loser_id]
        end

        puts "Updating skills for #{game_id}, team #{winner_ids.join(',')} won by #{winning_margin} over #{loser_ids.join(',')}"
        manager.process_game(winning_players, winning_margin, losing_players, losing_margin)

        winning_players.each { |player| player.save }
        losing_players.each { |player| player.save }
      end
    end
  end
end
