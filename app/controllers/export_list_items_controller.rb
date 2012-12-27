class ExportListItemsController < ApplicationController
  
  def form
    @export_data = ExportData.new((params[:export_data] || {}).merge({
      student_ids: current_user.export_list_student_ids,
      kind: params[:export_kind],
      type_id: params[:export_id],
      user_id: current_user.id
    }), as: current_role)
    
    view = @export_data.is_request? ? 'request' : 'waiting'
    
    # Shortcircuit submission process if there is nothing to input.
    if @export_data.is_zpass? || (@export_data.is_print? && @export_data.template.prompts.empty?)
      if @export_data.save
        Resque.enqueue(ExportJob, @export_data.id)
        session[:pending_export_data_id] = @export_data.id
        load_export_jobs if view == 'waiting'
        render view
      end
    elsif request.post?
      if @export_data.save
        Resque.enqueue(ExportJob, @export_data.id)
        session[:pending_export_data_id] = @export_data.id
        load_export_jobs if view == 'waiting'
        render json: {
          page: ERB::Util.html_escape(render_to_string(view))
        }
      else
        render json: {
          success: false,
          page: ERB::Util.html_escape(render_to_string('form'))
        }
      end
    end
  end
  
  def waiting
    load_export_jobs
  end
  
  def select
  end
  
  def view_request
    @request = params[:view_request]
    render 'export_list_items/view_request'
  end
  
  def clear
    current_user.export_list_items.delete_all
    render nothing: true
  end
  
  def toggle
    list_items = current_user.export_list_items.where(student_id: params[:student_id])
    removed = false
    if list_items.any?
      list_items.destroy_all
      removed = true
    else
      current_user.export_list_students << Student.where(id: params[:student_id])
    end
    render json: export_list_count_and_styles.merge(removed: removed)
  end
  
  def find_collection
    coll = current_user.export_list_students.includes(:users).with_permissions_to(:show)
    coll = coll.order('students.last_name').limit(offset_amount).offset(params[:offset].to_i)
    if params[:order].present? &&
      (match = /(\w+)\.(\w+) (asc|desc)/.match(params[:order])) &&
      match[1] == 'students' &&
      Student.column_names.include?(match[2])
        coll = coll.reorder(params[:order])
    end
    coll
  end
  
  private
  
  def load_export_jobs
    @pending = false
    if Resque.peek('export') || Resque.working.any?
      Resque.peek('export', 0, 1000).each do |job|
        if session[:pending_export_data_id] == job['args'].first
          @pending = true
          break
        end
      end
      Resque.working.each do |worker|
        if worker.job['queue'] == 'export'
          if session[:pending_export_data_id] == worker.job['payload']['args'].first
            @pending = true
            break
          end
        end
      end
      return false
    end
    
    unless @pending
      @finished = ExportData.find(session[:pending_export_data_id])
    end
    
  end

end