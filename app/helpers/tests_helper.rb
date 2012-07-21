module TestsHelper
  
  PARENTS[:tests] = [Student, Period, User, School, District]
  
  FIELDS[:tests] = {
    index: [:type, :data, :student],
    show: { fields: [:type, :data], relations: [] },
    form: { fields: [], relations: [] }
  }
  
end
