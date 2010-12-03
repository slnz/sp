class SpProjectStaff < SpUser
  def can_search?() true; end

  def role
    'Project Staff/Student Leader'
  end
end
