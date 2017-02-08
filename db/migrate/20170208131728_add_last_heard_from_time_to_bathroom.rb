class AddLastHeardFromTimeToBathroom < ActiveRecord::Migration
  def change
    add_column :bathrooms, :last_heard_from_time, :datetime
  end
end
