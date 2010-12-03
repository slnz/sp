class SpGeneralStaff < SpUser
  def can_search?() true; end
  
  def role
    'General Staff'
  end
end
