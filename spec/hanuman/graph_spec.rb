require 'spec_helper'

require 'gorillib/builder'
require 'hanuman/stage'
require 'hanuman/slot'
require 'hanuman/graph'

describe Hanuman::Graph, :helpers => true do

  # it 'makes a tree' do
  #   example_graph.tree.should == {
  #     :name => :pie,
  #     :inputs => [:bake_pie],
  #     :stages => [
  #       {:name=>:make_pie, :inputs=>[:crust, :filling]},
  #       {:name=>:bake_pie, :inputs=>[:make_pie]}
  #     ],
  #     }
  # end

end
