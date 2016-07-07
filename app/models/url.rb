class Url < ActiveRecord::Base
  has_many :payload_requests

  validates :root_url, presence: true
  validates :path, presence: true

  def self.all_paths
    Url.pluck(:path).uniq
  end

  def self.all_roots
    Url.pluck(:root_url).uniq
  end

  def self.most_to_least
    grouped = Url.group([:root_url] + [:path]).count

    array = grouped.sort_by do |key, value|
      value
    end.reverse


    sorted = array.map do |url, number|
      url.join
    end
  end

  def self.assemble_url(id)
    url = find(id)
    url.root_url + url.path
  end

  def self.response_times(id)
    url = find(id)
    url.payload_requests.pluck(:responded_in).sort.reverse
  end

  def self.verbs_used(id)
    requests = PayloadRequest.select(:request_type_id).where("url_id" == id)
    verb_ids = requests.pluck(:request_type_id).uniq

    verbs = verb_ids.map do |id|
      RequestType.find(id).name
    end
  end

end
