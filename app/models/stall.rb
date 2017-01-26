class Stall < ActiveRecord::Base
    belongs_to :bathroom

    def occupied?
      state
    end
end
