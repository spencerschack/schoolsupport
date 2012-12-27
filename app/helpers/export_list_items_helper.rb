module ExportListItemsHelper
  
  SORTS[:export_list_items] = {
    identifier: 'students.identifier',
    name: 'students.last_name',
    grade: 'students.grade'
  }
  
  FIELDS[:export_list_items] = {
    index: [:identifier, :name, :grade, :teacher]
  }
  
end