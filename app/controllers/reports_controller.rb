class ReportsController < ApplicationController
  LEADERBOARD_DEVIATION_CUTOFF = 3.0

  def index
    @players = Player.all.order(id: :asc)
  end

  def history

  end

  def leaderboard
    @players = Player
                   .where('rating_deviation < ?', LEADERBOARD_DEVIATION_CUTOFF)
                   .order(rating_skill: :desc)
  end

  def player
    player_id = params[:player_id].to_i
    @player = Player.find_by(:id => player_id)

    game_types = { 2 => 'Singles', 4 => 'Doubles' }

    @stats = {}
    @players = {}

    # Singles and doubles
    game_types.each do |player_count, type_name|
      last_id = 0
      wins = 0
      losses = 0
      biggest_win = 0
      biggest_loss = 0
      player_ids_beat = {}
      player_ids_beat_by = {}

      # Iterate through chunks of history records
      loop do
        # @type chunk [Array<GameHistory>]
        chunk = GameHistory
                    .where('player_id = ? AND player_count = ? AND id > ?', player_id, player_count, last_id)
                    .limit(50)
                    .order('id asc')

        puts "Processing chunk of #{chunk.length} rows for count #{player_count} for #{@player.name} id #{player_id}\n"
        break if !chunk || chunk.length == 0

        chunk.each do |result|
          # @type result [GameHistory]
          game_records = GameHistory.where(:game_id => result['game_id'])

          if result.win
            # Big winner
            wins += 1
            get_opposing_player_ids_for_game(player_id, result.win, game_records).each do |opponent_id|
              unless player_ids_beat.has_key?(opponent_id)
                player_ids_beat[opponent_id] = 0
              end
              player_ids_beat[opponent_id] += 1
            end
            margin = result.player_team_score - result.opponent_team_score
            if margin > biggest_win
              biggest_win = margin
            end
          else
            # LOSER
            losses += 1
            get_opposing_player_ids_for_game(player_id, result.win, game_records).each do |opponent_id|
              unless player_ids_beat_by.has_key?(opponent_id)
                player_ids_beat_by[opponent_id] = 0
              end
              player_ids_beat_by[opponent_id] += 1
            end
            margin = result.opponent_team_score - result.player_team_score
            if margin > biggest_loss
              biggest_loss = margin
            end
          end

          if result.id > last_id
            last_id = result.id
          end
        end
      end

      player_id_beat, beat_count = player_ids_beat.max_by{ |k,v| v }
      player_id_beat_by, beat_by_count = player_ids_beat_by.max_by{ |k,v| v }

      @players[type_name] = {
          :most_beat => {
              :player => Player.find_by(:id => player_id_beat),
              :count => beat_count
          },
          :most_beat_by => {
              :player => Player.find_by(:id => player_id_beat_by),
              :count => beat_by_count
          },
      }

      @stats[type_name] = {
        :wins => wins,
        :losses => losses,
        # :biggest_win => biggest_win,
        # :biggest_loss => biggest_loss,
      }
    end
    @total_wins = @stats['Singles'][:wins] + @stats['Doubles'][:wins]
    @total_losses = @stats['Singles'][:losses] + @stats['Doubles'][:losses]
  end

  private

  # @param [Numeric] player_id
  # @param [Boolean] is_winner
  # @param [Array<GameHistory>] game_records
  def get_opposing_player_ids_for_game(player_id, is_winner, game_records)
    out = []
    # @type game_record [GameHistory]
    game_records.each do |game_record|
      if (game_record.player_id != player_id) &&
          (game_record.win != is_winner)
        out << game_record.player_id
      end
    end
    out
  end


end
