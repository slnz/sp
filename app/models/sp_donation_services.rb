class SpDonationServices < SpUser
  def can_upload_ds?() true; end

  def role
    'Donation Services'
  end
end
