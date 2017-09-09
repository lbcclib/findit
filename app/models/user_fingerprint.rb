# An analytics table that stores salient
# information about Users
class UserFingerprint < ActiveRecord::Base
  visitable
  validates_uniqueness_of :visit_id
end
