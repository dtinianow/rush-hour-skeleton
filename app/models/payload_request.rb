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
    PayloadRequest.average(:responded_in)
  end

  def self.max_response_time
    PayloadRequest.maximum(:responded_in)
  end

  def self.min_response_time
    PayloadRequest.minimum(:responded_in)
  end

  def self.most_frequent_request_type
    verbs = pluck(:request_type_id).sort
    verb_count = verbs.each_with_object(Hash.new(0)) { |verb, hash| hash[verb] += 1 }
    id = verb_count.max_by { |verb, count| count }.first
    RequestType.find(id).name
  end

  def self.all_request_types
    ids = pluck(:request_type_id).uniq
    ids.map {|id| RequestType.find(id).name}
  end

  def self.most_to_least
    ids = group(:url_id).count
    sorted_ids = ids.sort_by { |key, value| value }.reverse
    sorted_ids.map {|id| Url.assemble_url(id[0])}
  end

  def self.browsers
    ids = group(:u_agent_id).count
    ids.map {|key, value| [UAgent.find(key).browser, value]}.to_h
  end

  def self.operating_systems
    ids = group(:u_agent_id).count
    ids.map {|key, value| [UAgent.find(key).operating_system, value]}.to_h
  end

  def self.all_resolutions
    ids = group(:resolution_id).count
    ids.map {|key, value| ["#{Resolution.find(key).width} x #{Resolution.find(key).height}", value]}.to_h
  end

  def self.all_client_paths
    ids = pluck(:url_id).uniq
    ids.map {|id| Url.find(id).path}
  end

end
