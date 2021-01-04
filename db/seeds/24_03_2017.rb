photo_approval_report_master = ReportMaster.find_by(report_name: 'photo_approval')

columns1 = %w(PHOTO PHOTO_ID)

columns1.each do |c|
  rmf = ReportMasterField.find_by(field_name: c.downcase)
  ReportMasterFieldAssociation.find_or_create_by(report_master_id: photo_approval_report_master.id, report_master_field_id: rmf.id).destroy
end

photo_approval_report_master.reload.update_report_blocks

columns1 = %w(STATUS_CHANGED_REASONS)

columns1.each do |c|
  rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
  ReportMasterFieldAssociation.find_or_create_by(report_master_id: photo_approval_report_master.id, report_master_field_id: rmf.id)
end

photo_approval_report_master.reload.update_report_blocks
