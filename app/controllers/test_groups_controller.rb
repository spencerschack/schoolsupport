class TestGroupsController < ApplicationController

  def find_collection
    super.order('test_groups.name')
  end

end
