class ProjectSweeper < ActionController::Caching::Sweeper
  observe SpProject
  def after_create(project)
    expire_cache_for(project)
  end
  def after_update(project)
    expire_cache_for(project)
  end
  def after_destroy(project)
    expire_cache_for(project)
  end
  
  private
  def expire_cache_for(project)
    unless Rails.env.test?
      expire_page('/projects/index.xml')
      expire_page('/projects/index.html')
    end
  end
end