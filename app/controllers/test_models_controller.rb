class TestModelsController < ApplicationController

  def find_collection
    super.order('test_models.name')
  end

end
