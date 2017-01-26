class Stall < ActiveRecord::Base
    belongs_to :bathroom
    has_many :stall_stats

    def occupied?
      state
    end
end
