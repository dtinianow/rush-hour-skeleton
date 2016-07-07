class Resolution < ActiveRecord::Base
  has_many :payload_requests

  validates :width, presence: true
  validates :height, presence: true

  def self.resolutions
    all.map do |object|
      count = PayloadRequest.where(resolution_id: object.id).count
      res = object.width * object.height
      [res, count]
    end.to_h
  end

end
