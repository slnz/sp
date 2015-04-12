require 'spec_helper'

describe ProjectFilter do
  context '#filter' do
    it 'should filter' do
      p1 = create(:sp_project)
      p2 = create(:sp_project)
      p3 = create(:sp_project)
      f = ProjectFilter.new(id: p1.id, ids: "#{p1.id}, #{p2.id}", name: p1.name, name_like: p1.name[0,2], status: p1.project_status, year: p1.year, primary_partner: p1.primary_partner, not_primary_partner: "NOT_PP")
      expect(f.filter(SpProject.all)).to eq([p1])
    end
  end
end
