class ProjectMailer < ActionMailer::Base
  default :from => "Summer Projects <gosummerproject@cru.org>"
  
  def team_email(to, from, cc, files, subject, body)
    files.each do |file|
      attachments[file.original_filename] = File.read(file.tempfile)
    end
    mail(:to => to, :from => from, :cc => cc, :subject => subject) do |format|
      format.html {render :text => body}
    end
  end
end
