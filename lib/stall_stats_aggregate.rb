class StallStatsAggregate

  #The value of a bucket is the sum of the percentage of stall use for that time slot. 
  #The max value should be the number of stalls.
  def self.create_buckets(bathroom, minutes, day)
    time = day

    stats = bathroom.stalls.map { |stall| stall.stall_stats.where("usage_end > ? AND usage_start < ? AND usage_end IS NOT NULL", day, day + 1.day) }
    buckets = {}
    (0..(((day + 1.day) - day) / minutes.minutes)).each do |i|
      buckets[time.in_time_zone('Eastern Time (US & Canada)') + (i * minutes).minutes] = 0
    end
    Rails.logger.fatal "Buckets: #{buckets.keys.to_s}"
    # Rails.logger.fatal "CREATING BUCKETS"
    stats.each do |stall_stats|
      stall_stats.each do |stat|
        next if stat.usage_start.nil? or stat.usage_end.nil?
        start_bucket = self.time_to_previous_bucket_key(minutes, stat.usage_start)
        end_bucket = self.time_to_previous_bucket_key(minutes, stat.usage_end)
        Rails.logger.fatal "Start bucket: #{start_bucket} --- #{buckets[start_bucket]}"
        #Easy case
        # Rails.logger.fatal "MINUTES #{minutes} #{minutes.minutes} STALL: #{stat.stall_id}"
        if start_bucket == end_bucket
          buckets[start_bucket] += (stat.usage_end - stat.usage_start) / minutes.minutes
          # Rails.logger.fatal "EASY CASE #{stat.usage_start} -> #{stat.usage_end} = #{(stat.usage_end - stat.usage_start).to_i} / #{minutes.minutes} = #{(stat.usage_end - stat.usage_start) / minutes.minutes}"
        else #Harder case
          buckets[start_bucket] += ((start_bucket + minutes.minutes) - stat.usage_start) / minutes.minutes
          buckets[end_bucket] += ((stat.usage_end - end_bucket) / minutes.minutes)
          long_poop_bucket = start_bucket + minutes.minutes
          # Rails.logger.fatal "START #{stat.usage_start} -> #{stat.usage_end} #{((start_bucket + minutes.minutes) - stat.usage_start) / minutes.minutes}"
          # Rails.logger.fatal "END #{stat.usage_start} -> #{stat.usage_end} #{((stat.usage_end - end_bucket) / minutes.minutes)}"
          # Rails.logger.fatal "LONG POOP BUCKET #{stat.usage_start} -> #{stat.usage_end} #{start_bucket + minutes.minutes}"
          (0..((end_bucket - long_poop_bucket) / minutes.minutes)).each do |i|
            # Rails.logger.fatal "LONG POOP #{((start_bucket + minutes.minutes) - stat.usage_start) / minutes.minutes}"
            buckets[long_poop_bucket + (i * minutes).minutes] += 1
          end
        end
      end
    end
    # Rails.logger.fatal "CREATING BUCKETS FINISHED"
    buckets.map { |k, v| [k.in_time_zone('Eastern Time (US & Canada)').strftime('%I:%M %p').gsub(/^0/, ''), v] }
  end

  def self.time_to_previous_bucket_key(bucket_duration, time)
    array = time.to_a
    quarter = ((array[1] % 60) / (bucket_duration.to_f)).floor
    array[1] = (quarter * bucket_duration) % 60
    array[0] = 0
    Time.local(*array).in_time_zone('Eastern Time (US & Canada)')
  end

end