class ProjectMailer < ActionMailer::Base
  default :from => "Summer Projects <gosummerproject@uscm.org>"
  
  def team_email(to, from, cc, files, subject, body)
    files.each do |file|
      attachments[file.original_filename] = file
    end
    mail(:to => to, :from => from, :cc => cc, :subject => subject) do |format|
      format.html {render :text => body}
    end
  end
end
