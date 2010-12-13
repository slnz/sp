class SpDonationServices < SpUser
  def can_upload_ds?() true; end
  def can_see_dashboard?() true; end
  
  def scope(partner = nil)
    if partner
      @scope ||= ['primary_partner like ? OR secondary_partner like ? OR tertiary_partner like ?' , partner, partner, partner]
    else
      @scope ||= ['1=1'] # all projects
    end
  end

  def role
    'Donation Services'
  end
end
