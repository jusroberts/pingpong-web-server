class Bathroom < ActiveRecord::Base
    has_many :stalls
    validates_uniqueness_of :name
end
