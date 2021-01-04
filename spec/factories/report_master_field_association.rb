FactoryBot.define do
  factory(:report_master_field_association) do
    deleted_at nil
    proc_block "proc do |_registration|\n      if _registration.try(:event).try(:sy_event_company_id).present? then\n        _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil\n      else\n        _registration.try(:event_order_line_item_id).present? ? _registration.event_order_line_item_id : nil\n      end\n    end"
    report_master_field_id 1
    report_master_id 1
  end
end
