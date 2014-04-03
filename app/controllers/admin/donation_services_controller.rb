require 'csv'
class Admin::DonationServicesController < ApplicationController
  before_filter :cas_filter, :authentication_filter
  before_filter :check_has_permission

  layout 'admin'

  def index
  end

  def download

    headers['Content-Type'] = "text/tab"
    headers['Content-Disposition'] = 'attachment; filename="sp_need_account_no.txt"'
    headers['Cache-Control'] = ''

    send_data(SpDonationServices.generate_file(current_person), filename: 'sp_need_account_no.txt', type: 'text/tab')
  end

  def upload
    @error_messages = Array.new
    unless params[:upload].present? && params[:upload][:upload].present?
      @error_messages << 'Please upload a .csv file'
      return
    end
    upload = params[:upload][:upload]

    begin
      @filename = upload.original_filename
    rescue NoMethodError
      @error_messages << 'Invalid upload'
      return
    end

    begin
      @warning_messages = Array.new
      designation_numbers_to_update = Hash.new
      persons_to_update = Hash.new
      row_num = 0
      Excelsior::Reader.rows(upload) do |row|
        row_num += 1
        if row.length < 3
          @error_messages << "Row #{row_num} is invalid: too short"
        else
          person_id = row[2]
          donor_number = row[1]
          designation_number = row[0]
          unless person_id.present? && designation_number.present? && designation_number != 0 && donor_number.present?
            @error_messages << "Row #{row_num} is invalid: missing required data"
          else
            begin
              designation_numbers_to_update[person_id] = designation_number
              persons_to_update[person_id] = donor_number
            rescue ActiveRecord::RecordNotFound
              @error_messages << "Person #{person_id} or subsequent does not exist"
            end
          end
        end
      end
      @error_messages << "File contains no rows" if row_num == 0
    # rescue CSV::IllegalFormatError
      # @error_messages << "csv file is invalid"
    end
    if !@error_messages.empty?
      return
    end

    @num_emails_sent = 0
    designation_numbers_to_update.each do |person_id, designation_number|
      padded_designation_number = designation_number.to_s.rjust(7, "0")
      person = Person.find(person_id)
      donor_number = persons_to_update[person_id]

      record = SpApplication.where(:person_id => person_id).where("year >= ?", SpApplication.year).first
      record ||= SpStaff.where(:person_id => person_id).where("year >= ?", SpApplication.year).first

      if record.present?
        project_id = record.project_id
        unless project_id.present?
          @warning_messages << "Person #{person_id} is not assigned to a project; skipping"
        else
          # if (application.designation_number == padded_designation_number && person.donor_number == donor_number)
          if record.designation_number == padded_designation_number && person.donor_number == donor_number
            @warning_messages << "Person #{person_id} has already been assigned " +
              "this designation number (#{padded_designation_number}) " +
              "and has already been assigned this donor id (#{donor_number}); no update necessary"
          else
            if record.designation_number.present? && record.designation_number != padded_designation_number
              @warning_messages << "Person #{person_id} was previously assigned a different " +
                "designation number (#{record.designation_number}); reassigning to #{padded_designation_number}"
            end
            if !person.donor_number.blank? && person.donor_number != donor_number
              @warning_messages << "Person #{person_id} was previously assigned a different donor id (#{person.donor_number}); reassigning to #{donor_number}"
            end

            # Update Records
            record.designation_number = padded_designation_number
            person.donor_number = donor_number

            if !record.valid?
              @warning_messages << "Person #{person_id} or subsequent record is corrupted and cannot be updated; " +
               "please contact help@cru.org"
            else
              project = SpProject.find(project_id)
              leaders = Hash.new
              leaders["Project Director (Male)"] = project.pd
              leaders["Project Director (Female)"] = project.apd
              leaders["Operations Project Director"] = project.opd
              leaders["Coordinator"] = project.coordinator
              recipients = Array.new
              leaders.each do |position, leader|
                if leader
                  if leader.email.blank?
                    @warning_messages << "#{position} for project #{project.id} does not have an email address"
                  else
                    recipients << leader.email
                  end
                end
              end
              record.save!
              person.save!
              if recipients.empty?
                @warning_messages << "No leaders have been notified of person #{person_id}'s designation number assignment"
              else
                Notifier.notification(recipients, # RECIPIENTS
                                      "gosummerproject@cru.org", # FROM
                                      "Designation Number Assigned", # LIQUID TEMPLATE NAME
                                      {'name' => person.try(:informal_full_name),
                                       'project_name' => project.name,
                                       'email' => person && person.current_address ? person.current_address.email : nil,
                                       'designation_number' => padded_designation_number,
                                       'donor_number' => donor_number}).deliver
                @num_emails_sent += 1
              end
            end
          end
        end
      else
        @warning_messages << "Person #{person_id} is not assigned to a project; skipping"
      end
    end
  end

  protected

  def check_has_permission
    unless sp_user.can_upload_ds?
      flash[:error] = "You don't have permission to upload account numbers."
      redirect_to(request.referrer ? :back : '/admin')
      return false
    end
  end
end
