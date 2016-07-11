class Url < ActiveRecord::Base
  has_many :payload_requests
  has_many :request_types, through: :payload_requests
  has_many :referred_bies, through: :payload_requests
  has_many :u_agents, through: :payload_requests

  validates :root_url, presence: true
  validates :path, presence: true

  def self.all_paths
    pluck(:path).uniq
  end

  def self.all_roots
    pluck(:root_url).uniq
  end

  def self.assemble_url(id)
    url = find(id)
    url.root_url + url.path
  end

  def self.response_times(id)
    url = find(id)
    url.payload_requests.pluck(:responded_in).sort.reverse
  end

  def self.max_response_time(id)
    find(id).payload_requests.maximum(:responded_in)
  end

  def self.min_response_time(id)
    find(id).payload_requests.minimum(:responded_in)
  end

  def self.average_response_time(id)
    find(id).payload_requests.average(:responded_in)
  end

  def self.verbs_used(id)
    find(id).request_types.group(:name).count.sort_by{|name, count| name}.to_h
  end

  def self.top_referrers(id)
    referrers = PayloadRequest.select(:referred_by_id).where("url_id" == id)
    referrer_ids = referrers.pluck(:referred_by_id)

    id_hash = referrer_ids.group_by {|number| number}

    id_array = id_hash.values.sort_by {|value| value.count}

    id_array.reverse.flatten.uniq.map do |id_number|
      ReferredBy.find(id_number).root_url + ReferredBy.find(id_number).path
    end[0..2]
  end

  def self.top_user_agents(id)
    agents = PayloadRequest.select(:u_agent_id).where("u_agent_id" == id)
    agent_ids = agents.pluck(:u_agent_id)

    id_hash = agent_ids.group_by {|number| number}

    id_array = id_hash.values.sort_by {|value| value.count}

    id_array.reverse.flatten.uniq.map do |id_number|
      "#{UAgent.find(id_number).browser}; " + "#{UAgent.find(id_number).operating_system}"
    end[0..2]
  end
end
