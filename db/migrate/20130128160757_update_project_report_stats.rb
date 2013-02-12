class SpProject < ActiveRecord::Base
end

class UpdateProjectReportStats < ActiveRecord::Migration
  def self.up
    change1 = SpProject.where(report_stats_to: 'Other Cru ministry')
    change1.update_all({report_stats_to: 'Other Cru ministry'}) if change1.present?

    change2 = SpProject.where(report_stats_to: 'Campus Ministry - Global Missions summer project')
    change2.update_all({report_stats_to: 'Campus Ministry - Global Missions summer project'}) if change2.present?
  end

  def self.down
    change1 = SpProject.where(report_stats_to: 'Other Cru ministry')
    change1.update_all({report_stats_to: 'Other Cru ministry'}) if change1.present?

    change2 = SpProject.where(report_stats_to: 'Campus Ministry - Global Missions summer project')
    change2.update_all({report_stats_to: 'Campus Ministry - Global Missions summer project'}) if change2.present?
  end
end
