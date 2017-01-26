class Stall < ActiveRecord::Base
    belongs_to :bathroom
    has_many :stall_stats

    def occupied?
      state
    end

    def handicap?
      bathroom.stalls.count - 1 == number
    end
end
