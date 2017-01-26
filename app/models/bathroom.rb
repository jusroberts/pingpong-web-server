class Bathroom < ActiveRecord::Base
    has_many :stalls
    validates_uniqueness_of :name

    def is_full?
      stalls.select { |s| s.occupied? == true }.count == stalls.count
    end
end
