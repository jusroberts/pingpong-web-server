class StreakHelper
  # Updates the current streak (@room.streak) and streak history based on the increment
  def update_streak_increment(team, streak_history)
    if streak_history.length > 0
      current_streak = streak_history[streak_history.length - 1]
    else
      current_streak = 0
    end
    streak_change = 0
    if team == "a"
      streak_change += 1
    else
      streak_change += -1
    end
    new_streak = current_streak + streak_change
    if new_streak.abs < current_streak.abs
      # The the other team has broken the streak
      new_streak = streak_change
    end
    streak_history.push(new_streak)
    return streak_history
  end

  # Looks at the streak history and removes the last streak change corresponding
  # to the team that decremented the score. Then, rebuild the streak history so that it matches
  # the current game scores. Positive streak values correspond to team a, negative to team b.
  # For example:
  #   streak_history: -1,-2,-3,1,2,3
  #   team who decremented: team b (positive streak)
  #   The updated streak history would be : -1,-2,1,2,3
  #   If team a had decremented, it would be: -1,-2,-3,1,2
  # Additionally, after the streak history is rebuilt, the value of @room.streak is updated as well.
  def update_streak_decrement(team, streak_history)
    if team == "a"
      team_a_or_b = true
    else
      team_a_or_b = false
    end

    number_popped_off = 0
    matching_streak_found = false

    while streak_history.length > 0 && !matching_streak_found
      previous_streak = streak_history.pop
      if is_streak_for_current_team(team_a_or_b, previous_streak)
        matching_streak_found = true
      else
        number_popped_off += 1
      end
    end
    streak_history = rebuild_streak_history(team_a_or_b, streak_history, number_popped_off)
    return streak_history
  end

  def get_new_streak(streak_history)
    if streak_history.length > 0
      return streak_history[streak_history.length-1]
    else
      return 0
    end
  end

  def is_streak_for_current_team(team_a_or_b, streak)
    sign_of_streak = streak > 0
    return team_a_or_b == sign_of_streak
  end

  def rebuild_streak_history(team_a_or_b, streak_history, amount_to_adjust)
    if team_a_or_b
      adjustment_factor = -1
    else
      adjustment_factor = +1
    end

    #find out where we need to start from
    if streak_history.length > 0 && !is_streak_for_current_team(team_a_or_b, streak_history[streak_history.length-1])
      starting_point = streak_history[streak_history.length-1]
    else
      starting_point = 0
    end

    array_to_append = []
    value_to_append = starting_point
    amount_to_adjust.times {
      value_to_append += adjustment_factor
      array_to_append.push(value_to_append)

    }
    return streak_history + array_to_append
  end
end