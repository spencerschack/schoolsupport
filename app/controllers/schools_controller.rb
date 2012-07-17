class SchoolsController < ApplicationController
  
  def collection
    super.includes(:district)
  end
  
end
