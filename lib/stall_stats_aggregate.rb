class StallStatsAggregate

  #The value of a bucket is the sum of the percentage of stall use for that time slot. 
  #The max value should be the number of stalls.
  def self.create_buckets(bathroom, minutes, day)
    time = day

    stats = bathroom.stalls.map { |stall| stall.stall_stats.where("usage_end > ? AND usage_start < ?", day, day + 1.day) }
    buckets = {}
    (0..(((day + 1.day) - day) / minutes.minutes)).each do |i|
      buckets[time + (i * minutes).minutes] = 0
    end

    stats.each do |stall_stats|
      stall_stats.each do |stat|
        start_bucket = self.time_to_previous_bucket_key(minutes, stat.usage_start)
        end_bucket = self.time_to_previous_bucket_key(minutes, stat.usage_end)
        #Easy case
        if start_bucket == end_bucket
          buckets[start_bucket] += (stat.usage_end - stat.usage_start) / minutes.minutes
        else #Harder case
          buckets[start_bucket] += ((start_bucket + minutes.minutes) - stat.usage_start) / minutes.minutes
          buckets[end_bucket] += ((stat.usage_end - end_bucket) / minutes.minutes)
          long_poop_bucket = start_bucket + minutes.minutes
          (0..((end_bucket - long_poop_bucket) / minutes.minutes)).each do |i|
            buckets[long_poop_bucket + (i * minutes).minutes] += 1
          end
        end
      end
    end
    buckets.map { |k, v| [k.in_time_zone('Eastern Time (US & Canada)').strftime('%I:%M %p').gsub(/^0/, ''), v] }
  end

  def self.time_to_previous_bucket_key(bucket_duration, time)
    array = time.to_a
    quarter = ((array[1] % 60) / (bucket_duration.to_f)).floor
    array[1] = (quarter * bucket_duration) % 60
    array[0] = 0
    Time.local(*array)
  end

end