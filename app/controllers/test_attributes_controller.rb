class TestAttributesController < ApplicationController

  def find_collection
    if params[:search]
      super.where(parent_id: nil)
    else
      super
    end
  end

end
