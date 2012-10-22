class RequestMailer < ActionMailer::Base
  
  def request export
    @export = export
    @user = Authorization.current_user
    attachments["#{@export.certificate_title}.csv"] = generate_csv
    mail(subject: 'Print Request from School Support',
      to: 'spencer.s@shoobphoto.com',
      from: "#{@user.name} <#{@user.email}>")
  end
  
  def generate_csv
    CSV.generate do |csv|
      csv << ['ID', 'Last Name', 'First Name', 'Grade', 'Teacher']
      @export.students.each do |student|
        csv << [student.identifier, student.last_name, student.first_name, student.grade, student.users.first.try(:name)]
      end
    end
  end
  
end
