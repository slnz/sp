class Api::V1::ProjectsController < Api::V1::BaseController

  def index
    projects = ProjectFilter.new(params[:filters]).filter(SpProject.all)
    render render_options(projects, params[:order] || 'name')
  end

  def show
    project = SpProject.find(params[:id])
    render render_options(project)
  end

  private

  def available_includes
    []
  end

  def available_methods
    [:pd, :apd, :opd, :coordinator, :applicants, :staff, :volunteers]
  end
end
