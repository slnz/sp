class ProjectMailer < ActionMailer::Base
  default :from => "Summer Projects <summer.missions@cru.org>"
  
  def team_email(to, from, reply_to, cc, files, subject, body)
    files.each do |file|
      attachments[file.original_filename] = File.read(file.tempfile)
    end
    mail(:to => to, :from => from, :reply_to => reply_to, :cc => cc, :subject => subject) do |format|
      format.html {render :text => body}
    end
  end
end
