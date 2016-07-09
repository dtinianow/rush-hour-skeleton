class RequestType < ActiveRecord::Base
  has_many :payload_requests

  validates :name, presence: true

  # def self.all_request_types
  #   pluck(:name).uniq
  # end
end
