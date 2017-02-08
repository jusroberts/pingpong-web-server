class Bathroom < ActiveRecord::Base
    has_many :stalls
    validates_uniqueness_of :name

    def is_full?
      stalls.select { |s| s.occupied? == true }.count == stalls.count
    end

    def offline?
      return true if last_heard_from_time.nil?
      last_heard_from_time < 1.minute.ago
    end
end
