class ExportListItemsController < ApplicationController
  
  def export
    if params[:export_kind]
      unless params[:commit]
        params[:selected] ||=
          { :"#{controller_name.singularize}_ids" => params[:id] }
      end
      
      @export = Export.new
      @export.assign_attributes(
        (params[:selected] || {}).merge(params[:export] || {}).merge({
          kind: params[:export_kind],
          type_id: params[:export_id]
      }), as: current_role)
      
      if params[:commit]
        if @export.valid? && params[:export_kind] == 'request'
          RequestMailer.request_form(@export).deliver
        end
        respond_with @export
      else
        render 'application/export'
      end
    end
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