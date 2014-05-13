require 'diff_set'
require 'zk'
require 'celluloid'
require 'celluloid/autostart'

module DiffSet
  require 'diff_set/pairwise'
  require 'diff_set/pairwise_random_set'
  require 'diff_set/pairwise_priority_set'
end

module Cellect
  class << self
    attr_accessor :replicator, :node_affinity
  end
  
  require 'cellect/adapters'
  require 'cellect/replicator'
  require 'cellect/project'
  require 'cellect/grouped_project'
  require 'cellect/user'
  require 'cellect/api'
  
  Cellect.replicator = Replicator.pool size: 50
  Cellect.node_affinity = false
  
  def self.ready?
    Project.all.each do |project|
      return false unless project.ready?
    end
    
    true
  rescue
    false
  end
end
