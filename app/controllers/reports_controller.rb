class ReportsController < ApplicationController
  def index
    @players = Player.all
  end

  def player
    player_id = params[:player_id].to_i
    @player = Player.find_by(:id => player_id)
    last_id = 0

    game_types = { 2 => 'Singles', 4 => 'Doubles' }

    @stats = {}

    # Singles and doubles
    game_types.each do |player_count, type_name|
      wins = 0
      losses = 0
      player_ids_beat = {}
      player_ids_beat_by = {}

      # Iterate through chunks of history records
      loop do
        chunk = ActiveRecord::Base.connection.exec_query(
            "SELECT * FROM game_histories WHERE player_id = #{player_id} AND player_count = #{player_count} " +
                "AND id > #{last_id} ORDER BY ID ASC LIMIT 50")

        break if chunk.rows.length == 0

        chunk.each do |result|
          game_records = ActiveRecord::Base.connection.exec_query(
              "SELECT player_id, win FROM game_histories WHERE game_id = #{result['game_id']}")

          if result['win']
            # Big winner
            wins += 1
            get_opposing_player_ids_for_game(player_id, !!result['win'], game_records).each do |opponent_id|
              unless player_ids_beat.has_key?(opponent_id)
                player_ids_beat[opponent_id] = 0
              end
              player_ids_beat[opponent_id] += 1
            end
          else
            # LOSER
            losses += 1
            get_opposing_player_ids_for_game(player_id, !!result['win'], game_records).each do |opponent_id|
              unless player_ids_beat.has_key?(opponent_id)
                player_ids_beat_by[opponent_id] = 0
              end
              player_ids_beat_by[opponent_id] += 1
            end
          end

          if result['id'] > last_id
            last_id = result['id']
          end
        end
      end

      player_id_beat, beat_count = player_ids_beat.max_by{ |k,v| v }
      player_id_beat_by, beat_by_count = player_ids_beat_by.max_by{ |k,v| v }

      @stats[type_name] = {
        :wins => wins,
        :losses => losses,
        :most_beat => player_id_beat,
        :most_beat_count => beat_count,
        :most_beat_by => player_id_beat_by,
        :most_beat_by_count => beat_by_count,
      }
    end
  end

  private

  def get_opposing_player_ids_for_game(player_id, is_winner, game_records)
    out = []
    win_field = is_winner ? 1 : 0
    game_records.each do |game_record|
      if (game_record['player_id'] != player_id) &&
          (game_record['win'] != win_field)
        out << game_record['player_id']
      end
    end
    out
  end

  def get_output_player_hashes()

  end
end
