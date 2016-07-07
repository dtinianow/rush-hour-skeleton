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

  #all.select calls upon all of the uagent objects currently existing in the uagent table, selecting by browser or operating system, respectively, then joins that with the payload_requests table and returns all the uagent objects that coincide with the rule requiring the uagents.id to match the payload_request.u_agent_id (we can call upon the payload_requests table because of the dependency of has_many payload requests). That list of uagent objects is grouped according to browser and the number of appearances of the browser name is counted and becomes the key attached to the browser name. Amazing!

end
