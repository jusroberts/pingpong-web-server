class StallStatsAggregate

  #The value of a bucket is the sum of the percentage of stall use for that time slot. 
  #The max value should be the number of stalls.
  def self.create_buckets(bathroom, minutes, day)
    time = day

    stats = bathroom.stalls.map { |stall| stall.stall_stats.where("usage_start > ? AND usage_end < ? AND usage_end IS NOT NULL", day, day + 1.day) }
    buckets = {}
    (0..(((day + 1.day) - day) / minutes.minutes)).each do |i|
      buckets[time.in_time_zone('Eastern Time (US & Canada)') + (i * minutes).minutes] = 0
    end
    # Rails.logger.fatal "Buckets: #{buckets.keys.to_s}"
    # Rails.logger.fatal "CREATING BUCKETS"
    stats.each do |stall_stats|
      stall_stats.each do |stat|
        next if stat.usage_start.nil? or stat.usage_end.nil?
        buckets.each do |key, _|
          buckets[key] += self.percentage_in_slot(key, key + minutes.minutes, stat.usage_start, stat.usage_end)
        end
      end
    end
    # Rails.logger.fatal "CREATING BUCKETS FINISHED"
    buckets.map { |k, v| [k.in_time_zone('Eastern Time (US & Canada)').strftime('%I:%M %p').gsub(/^0/, ''), v] }
  end

  #Returns the percentage of a buckets time that a time slot occupies
  def self.percentage_in_slot(bucket_start, bucket_end, usage_start, usage_end)
    return self.time_in_slot(bucket_start, bucket_end, usage_start, usage_end) / (bucket_end - bucket_start)
  end

  #Returns the amount of time spent in a given time slot
  def self.time_in_slot(bucket_start, bucket_end, usage_start, usage_end)
    if (usage_start > bucket_end || usage_end < bucket_start) do
      return 0
    elsif (usage_start >= bucket_start && usage_end <= bucket_end)
      return usage_end - usage_start
    elsif (usage_start <= bucket_ending && usage_start >= bucket_start)
      return bucket_end - usage_start
    elsif (usage_end >= bucket_start && usage_end <= bucket_end)
      return usage_end - bucket_start
    else
      return bucket_end - bucket_start
    end
  end

  def self.time_to_previous_bucket_key(bucket_duration, time)
    array = time.to_a
    quarter = ((array[1] % 60) / (bucket_duration.to_f)).floor
    array[1] = (quarter * bucket_duration) % 60
    array[0] = 0
    Time.local(*array).in_time_zone('Eastern Time (US & Canada)')
  end

end