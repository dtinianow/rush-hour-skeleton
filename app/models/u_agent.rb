class UAgent < ActiveRecord::Base
  has_many :payload_requests

  validates :browser, presence: true
  validates :operating_system, presence: true

  def self.browser_breakdown
    all.select(:browser).joins(:payload_requests).where("u_agents.id" == "payload_request.u_agent_id").group(:browser).count
  end

  def self.os_breakdown
    all.select(:operating_system).joins(:payload_requests).where("u_agents.id" == "payload_request.u_agent_id").group(:operating_system).count
  end

end
