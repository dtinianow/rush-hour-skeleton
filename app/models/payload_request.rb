class PayloadRequest < ActiveRecord::Base
  belongs_to :url
  belongs_to :request_type
  belongs_to :resolution
  belongs_to :ip
  belongs_to :u_agent
  belongs_to :referred_by
  belongs_to :client

  validates :url_id, presence: true
  validates :requested_at, presence: true
  validates :responded_in, presence: true
  validates :referred_by_id, presence: true
  validates :request_type_id, presence: true
  validates :u_agent_id, presence: true
  validates :resolution_id, presence: true
  validates :ip_id, presence: true

  def self.average_response_time
    average(:responded_in).round(2)
  end

  def self.max_response_time
    maximum(:responded_in).round(2)
  end

  def self.min_response_time
    minimum(:responded_in).round(2)
  end

  def self.most_frequent_request_type
    id = group(:request_type_id).count.max_by { |key, value| value }.first
    RequestType.find(id).name
  end

  def self.all_request_types
    pluck(:request_type_id).uniq.map {|id| RequestType.find(id).name}
  end

  def self.most_to_least
    group(:url_id).count.sort_by { |key, value| value }.reverse.map {|id| Url.assemble_url(id[0])}
  end

  def self.browsers
    group(:u_agent_id).count.map {|key, value| [UAgent.find(key).browser, value]}.to_h
  end

  def self.operating_systems
    group(:u_agent_id).count.map {|key, value| [UAgent.find(key).operating_system, value]}.to_h
  end

  def self.all_resolutions
    group(:resolution_id).count.map {|key, value| ["#{Resolution.find(key).width} x #{Resolution.find(key).height}", value]}.to_h
  end

  def self.all_client_paths
    pluck(:url_id).uniq.map {|id| Url.find(id).path}
  end

end
