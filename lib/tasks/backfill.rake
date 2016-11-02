namespace :backfill do
  desc 'Data backfill tasks'
  task backfill_rating: :environment do
    player_cache = {}
    manager = RatingManager.new
    last_id = 0

    # Zero out all ratings before recalculating
    ActiveRecord::Base.connection.execute("UPDATE players SET rating_skill = #{RatingManager::TRUESKILL_MU}, rating_deviation = #{RatingManager::TRUESKILL_SIGMA}")

    loop do
      # Grab a chunk of game_ids
      game_ids = GameHistory
                     .where('game_id > ?', last_id)
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

        # @type [Hash{Integer => GameHistory}]
        player_histories = {}

        # @type game_record [GameHistory]
        game_records.each do |game_record|
          player_histories[game_record.player_id] = game_record

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
          # @type winner [Player]
          winner = player_cache[winner_id]
          puts "Winner id #{winner_id} before win processed skill: #{winner.rating_skill}, deviation: #{winner.rating_deviation}"
          winner
        end
        losing_players = loser_ids.map do |loser_id|
          unless player_cache.has_key?(loser_id)
            player_cache[loser_id] = Player.find_by(:id => loser_id)
          end
          loser = player_cache[loser_id]
          puts "Loser id #{loser_id} before lose processed skill: #{loser.rating_skill}, deviation: #{loser.rating_deviation}"
          loser
        end

        starting_skills = {}
        starting_deviations = {}

        # Store starting ratings so we can calculate differential
        players = winning_players + losing_players
        players.each do |player|
          starting_skills[player.id] = player.rating_skill
          starting_deviations[player.id] = player.rating_deviation
        end

        puts "Updating skills for #{game_id}, team #{winner_ids.join(',')} won by #{winning_margin} over #{loser_ids.join(',')}"
        manager.process_game(winning_players, winning_margin, losing_players, losing_margin)

        winning_players.each do |winner|
          winner.save
          puts "Winner id #{winner.id} after win processed skill: #{winner.rating_skill}, deviation: #{winner.rating_deviation}"
        end
        losing_players.each do |loser|
          loser.save
          puts "Loser id #{loser.id} after lose processed skill: #{loser.rating_skill}, deviation: #{loser.rating_deviation}"
        end

        # Calculate and store rating differentials
        # @type player [Player]
        players.each do |player|
          # @type [GameHistory]
          player_history = player_histories[player.id]
          player_history.skill_change = player.rating_skill - starting_skills[player.id]
          player_history.deviation_change = player.rating_deviation - starting_deviations[player.id]
          player_history.save
        end

        if game_id > last_id
          last_id = game_id
        end
      end
    end
  end
end
