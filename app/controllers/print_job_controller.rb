class PrintJobController < ApplicationController
  
  def new
    new_print_job_from_params
  end
  
  def create
    prawnto prawn: { skip_page_creation: @print_job.valid? }
    render 'create', formats: ['pdf']
  end
  
  protected
  
  def new_print_job_from_params
    @print_job ||= PrintJob.new(params[:print_job])
  end
  
end
