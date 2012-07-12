module Errors
  
  def self.included base
    #base.rescue_from StandardError, with: :server_error
  end
  
  protected
  
  # Called when declarative_authorization denies access to the requested page.
  def permission_denied
    render 'errors/forbidden'
  end
  
  private
  
  def server_error exception
    @exception = exception
    render 'errors/server_error'
  end
  
end