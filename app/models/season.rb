class Season < ActiveRecord::Base
  belongs_to :room
  before_save :clear_active
  def clear_active
    if self.active == true
      room.seasons.update_all(active: false)
    end
  end
end
