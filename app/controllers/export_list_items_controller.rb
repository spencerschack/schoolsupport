class ExportListItemsController < ApplicationController
  
  def form
    @export_data = ExportData.new((params[:export_data] || {}).merge({
      student_ids: current_user.export_list_student_ids,
      kind: params[:export_kind],
      type_id: params[:export_id],
      user_id: current_user.id
    }), as: current_role)

    if request.post?
      queued = @export_data.save && Resque.enqueue(ExportJob, @export_data.id)
      if @export_data.is_request?
        json_object = queued ? {} : { success: false }
        view = queued ? 'request' : 'form'
        render json: json_object.merge({
          page: ERB::Util.html_escape(render_to_string(view))
        })
      else
        redirect_to "/load_import_jobs?export_data_id=#{@export_data.id}"
      end
    end
    
    @export_data.valid? unless @export_data.is_request?
  end
  
  def waiting
    @pending = false
    params[:export_data_id] = params[:export_data_id].to_i
    
    if Resque.peek('export') || Resque.working.any?
      Resque.peek('export', 0, 1000).each do |job|
        if params[:export_data_id] == job['args'].first
          @pending = true
          break
        end
      end
      Resque.working.each do |worker|
        if worker.job['queue'] == 'export'
          if params[:export_data_id] == worker.job['payload']['args'].first
            @pending = true
            break
          end
        end
      end
    end
    
    unless @pending
      finished = ExportData.find(params[:export_data_id])
      if finished.try(:file?)
        redirect_to finished.file.url
      else
        render layout: false
      end
    else
      render layout: false
    end
  end
  
  def upload
    if request.post?
      if params[:upload][:file].respond_to?(:read)
        identifiers = params[:upload][:file].read.split("\n")
        if school = School.where(id: params[:upload][:school_id].to_i).first
          student_ids = school.students.where(identifier: identifiers).pluck(:id)
          if student_ids.any?
            insert_student_ids_into_export_list_items student_ids
            render json: {
              page: ERB::Util.html_escape(render_to_string('index'))
            }.merge(export_list_count_and_styles)
          else
            @error = 'Could not find any students with the given identifiers.'
          end
        else
          @error = 'Could not find selected school.'
        end
      else
        @error = 'Could not read file.'
      end
      if @error
        @error = "Upload failed. #{@error}"
        render json: {
          success: false,
          page: ERB::Util.html_escape(render_to_string('upload'))
        }
      end
    end
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

end