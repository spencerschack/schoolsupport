class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :handle_non_xhr
  
  layout 'xhr'
  
  include Methods
  include Variables
  include Parents
  include Resources
  include Response
  include Auth

  private
  
  # If the request is not xhr, render only the layout.
  def handle_non_xhr
    file_upload = params['X-Requested-With'] == 'IFrame'
    unless params[:print_job] || request.xhr? || file_upload
      if request.path != root_path
        redirect_to root_url, flash: { initial_path: corrected_path }
      else
        render 'blank', layout: 'application'
      end
    end
  end
  
end
