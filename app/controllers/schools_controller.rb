class SchoolsController < ApplicationController
  
  def find_collection
    super.eager_load(:district).order('schools.name')
  end
  
end
