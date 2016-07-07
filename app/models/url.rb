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

    sorted = []
    array.map do |url, number|
      sorted << url.join
    end
    sorted
  end

  def assemble_url
    self.root_url + self.path
  end

  def response_times
    self.payload_requests.pluck(:responded_in).sort.reverse
  end
end
