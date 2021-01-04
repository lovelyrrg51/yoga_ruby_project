class ReportMaster < ApplicationRecord
  acts_as_paranoid

  validates :report_name, presence: true, uniqueness: {case_sensitive: false}
  # validates :start_block, :final_block, presence: true

  serialize :required_params, JSON

  has_many :report_master_field_associations
  has_many :report_master_fields, through: :report_master_field_associations

  def update_report_blocks
    procs = self.send("report_#{self.report_name}")
    raise 'Please provide some proc block for report.' unless procs.present?

    # Update start and final block for report master, find by key _start_block and _final_block
    self.update_start_block = procs['_start_block']
    self.update_final_block = procs['_final_block']

    self.report_master_field_associations.order(:id).each do |report_master_ass|
      report_master_field = report_master_ass.report_master_field
      raise "Field not found for report master field association: #{report_master_ass.id}" unless report_master_field.present?

      field_proc = procs[report_master_field.field_name]

      next unless field_proc.present?

      report_master_ass.update_proc_block = field_proc
    end
  end

  private
  def update_start_block=(block)
    raise 'Block is missing.' unless block.present?
    self.update_columns(start_block: block.to_raw_source)
  end

  def update_final_block=(block)
    raise 'Block is missing.' unless block.present?
    self.update_columns(final_block: block.to_raw_source)
  end

  def report_event_registration
    procs = {}

    # Event Registration Report - Starts

    # Create event reistration report
    # event_registration_report_master = ReportMaster.find_or_create_by(report_name: 'event_registration', required_params: ['event_id'])

    # ["registration_number", "old_syid", "old_first_name", "old_last_name", "new_syid", "new_first_name", "new_last_name", "name_changed_date", "new_mobile", "new_email", "new_country", "new_state", "new_city", "new_street_address", "old_transaction_id", "new_transaction_id", "date_of_transaction", "old_seating_category", "new_seating_category", "old_category_amount", "new_category_amount", "old_discount", "new_discount", "difference_amount(paid/refunded)", "total_tax", "convienence_charges", "total_paid", "registration_status", "reg_ref_number", "registration_date", "event_name", "event_start_date", "event_end_date", "payment_status", "payment_method", "registration_id", "item_id", "forum_id", "forum_name", "medical_degree", "current_profession", "work_environment", "speciality_area", "bank_name", "admin_notes", "dd_date", "registered_by"]

    # columns.each do |c|
    #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
    #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_report_master.id, report_master_field_id: rmf.id)
    # end

    # event_registration_report_master.reload.update_report_blocks

    # Start block for event_registration
    procs['_start_block'] = Proc.new do |parent_task, params = {}|

      raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

      event = Event.preloaded_data.find_by_id(params[:event_id])

      raise 'Event cannot be blank.' unless event.present?

      # Assign default value to from and to
      from = params[:from].present? ? params[:from] : (Date.today - 10.years).to_s
      to = params[:to].present? ? params[:to] : (Date.today + 10.years).to_s

      if event.sy_event_company_id.present?
        event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', from, to).order('serial_number')
      else
        event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', from, to).order('event_order_line_item_id')
      end

      if params[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: params[:report_master_field_association_ids])
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: params[:report_master_id])
      end
      params[:batch_size] = (3e6 / (report_field_ass.size * 16)).to_i

      # Update file name in parent task config
      t_config = ActiveSupport::HashWithIndifferentAccess.new(parent_task.t_config)

      t_config[:file_name] = event.try(:event_name).truncate(40, omission: '... (continued)') + '_' + t_config[:file_name]

      parent_task.update_columns(t_config: t_config)

      parent_task.result = event_registrations.pluck(:id)
    end

    # Final block for event_registration
    procs['_final_block'] = Proc.new do |sub_task, ids, opts = {}|

      raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

      if opts[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: opts[:report_master_field_association_ids]).sort_by(&:id)
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: opts[:report_master_id]).sort_by(&:id)
      end

      header = report_field_ass.collect{|rfa| rfa.report_master_field.field_name.upcase}
      rows = []

      includable_data = [{sadhak_profile: [{ address: [:db_city, :db_state, :db_country] }, {medical_practitioners_profile: [:medical_practitioner_speciality_area]}]}, {event_order: [:registration_center_user, :registration_center, :event_registrations, :versions]}, {event_order_line_item: [:versions]}, :event_seating_category_association, :seating_category, :user, :versions, {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {registration_centers: [:registration_center_users]}, :event_tax_type_associations, :tax_types]}, {sy_club_member: [:sy_club]}]

      event_registrations = EventRegistration.where(id: ids).includes(includable_data)

      is_exposed = sub_task.parent_task.taskable.try(:super_admin?)

      event_registrations.each_with_index do |_registration, _index|
        row = []
        report_field_ass.each do |_report_field_ass|
          block = eval(_report_field_ass.proc_block.to_s)
          row.push(block.present? ? block.call(_registration, is_exposed) : nil)
        end
        rows.push(row)
      end

      file = GenerateExcel.generate(rows: rows, header: header, data_type: 'file')

      sub_task.result = {file: file, from: event_registrations.first.id, to: event_registrations.last.id, format: 'xls'}
    end

    # Writing blocks for event_registration report
    procs['registration_number'] = Proc.new do |_registration|
      if _registration.try(:event).try(:sy_event_company_id).present? then
        _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil
      else
         _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil
         # Deprecated on sandeep ji's request
        # _registration.try(:event_order_line_item_id).present? ? _registration.event_order_line_item_id : nil
      end
    end

    procs['old_syid'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      _registration_version = _registration.versions.last.try(:reify)
      old_sadhak_profile = _registration_version.try(:sadhak_profile)
      is_syid_changed = (old_sadhak_profile.present? and sadhak_profile.id != old_sadhak_profile.id)
      is_syid_changed ? old_sadhak_profile.try(:syid) : nil
    end

    procs['old_first_name'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      _registration_version = _registration.versions.last.try(:reify)
      old_sadhak_profile = _registration_version.try(:sadhak_profile)
      is_syid_changed = (old_sadhak_profile.present? and sadhak_profile.id != old_sadhak_profile.id)
      is_syid_changed ? old_sadhak_profile.try(:first_name) : nil
    end

    procs['old_last_name'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      _registration_version = _registration.versions.last.try(:reify)
      old_sadhak_profile = _registration_version.try(:sadhak_profile)
      is_syid_changed = (old_sadhak_profile.present? and sadhak_profile.id != old_sadhak_profile.id)
      is_syid_changed ? old_sadhak_profile.try(:last_name) : nil
    end

    procs['new_syid'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:syid)
    end

    procs['new_first_name'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:first_name)
    end

    procs['new_last_name'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:last_name)
    end

    procs['new_gender'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:gender)
    end

    procs['new_date_of_birth'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:date_of_birth).try(:strftime, '%b %d %Y')
    end

    procs['name_changed_date'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      _registration_version = _registration.versions.last.try(:reify)
      old_sadhak_profile = _registration_version.try(:sadhak_profile)
      is_syid_changed = (old_sadhak_profile.present? and sadhak_profile.id != old_sadhak_profile.id)
      is_syid_changed ? _registration_version.try(:version).try(:created_at).to_s : nil
    end

    procs['new_mobile'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:mobile) : nil
    end

    procs['new_email'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:email) : nil
    end

    procs['photo_id_uploaded'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:advance_profile).try(:advance_profile_photograph).present? ? 'Yes' : 'No'
    end

    procs['photo_id_approved'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:profile_photo_status) == 'pp_success' ? 'Yes' : 'No'
    end

    procs['photo_id_proof_uploaded'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:advance_profile).try(:advance_profile_identity_proof).present? ? 'Yes' : 'No'
    end

    procs['photo_id_proof_approved'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:photo_id_status) == 'pi_success' ? 'Yes' : 'No'
    end

    procs['photo_id_proof_number'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:advance_profile).try(:photo_id_proof_number).to_s : nil
    end

    procs['address_proof_uploaded'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:advance_profile).try(:advance_profile_address_proof).present? ? 'Yes' : 'No'
    end

    procs['address_proof_approved'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:address_proof_status) == 'ap_success' ? 'Yes' : 'No'
    end

    procs['photo_id_last_updated'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:advance_profile).try(:advance_profile_photograph).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
    end

    procs['photo_id_proof_last_updated'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:advance_profile).try(:advance_profile_identity_proof).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
    end

    procs['new_country'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:address).try(:country_name) : nil
    end

    procs['new_state'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:address).try(:state_name) : nil
    end

    procs['new_city'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:address).try(:city_name) : nil
    end

    procs['new_street_address'] = Proc.new do |_registration, is_exposed|
      sadhak_profile = _registration.sadhak_profile
      is_exposed ? sadhak_profile.try(:address).try(:street_address) : nil
    end

    procs['old_transaction_id'] = Proc.new do |_registration|
      # Get event order associated to current registration
      event_order = _registration.event_order
      event_order_version = nil
      if _registration.status == 'upgraded'
        (event_order.try(:versions) || []).reverse.each do |eov|
          if eov.reify.diff(event_order)[:transaction_id].present?
            event_order_version = eov.reify
            break
          end
        end
      else
        event_order_version = event_order.try(:versions).try(:last).try(:reify)
      end
      is_transaction_id_changed = (event_order_version.present? and event_order.try(:transaction_id) != event_order_version.transaction_id)
      is_transaction_id_changed ? event_order_version.try(:transaction_id) : nil
    end

    procs['new_transaction_id'] = Proc.new do |_registration|
      event_order = _registration.event_order
      event_order.try(:transaction_id)
    end

    procs['date_of_transaction'] = Proc.new do |_registration|
      # Get event order associated to current registration
      event_order = _registration.event_order
      event_order_version = nil
      if _registration.status == 'upgraded'
        (event_order.try(:versions) || []).reverse.each do |eov|
          if eov.reify.diff(event_order)[:transaction_id].present?
            event_order_version = eov.reify
            break
          end
        end
      else
        event_order_version = event_order.try(:versions).try(:last).try(:reify)
      end
      event_order_version.try(:version).try(:created_at).to_s
    end

    procs['old_seating_category'] = Proc.new do |_registration|
      _registration_version = _registration.versions.last.try(:reify)
      seating_category_association = _registration.event_seating_category_association
      old_seating_category_association = _registration_version.try(:event_seating_category_association)
      old_seating_category = old_seating_category_association.try(:seating_category)
      is_category_changed = (old_seating_category_association.present? and seating_category_association.try(:id) != old_seating_category_association.try(:id))
      is_category_changed ? old_seating_category.try(:category_name) : nil
    end

    procs['new_seating_category'] = Proc.new do |_registration|
      seating_category = _registration.seating_category
      seating_category.try(:category_name)
    end

    procs['old_category_amount'] = Proc.new do |_registration|
      _registration_version = _registration.versions.last.try(:reify)
      seating_category_association = _registration.event_seating_category_association
      old_seating_category_association = _registration_version.try(:event_seating_category_association)
      is_category_changed = (old_seating_category_association.present? and seating_category_association.try(:id) != old_seating_category_association.try(:id))
      is_category_changed ? ('%.2f' % old_seating_category_association.try(:price).to_f) : nil
    end

    procs['new_category_amount'] = Proc.new do |_registration|
      seating_category_association = _registration.event_seating_category_association
      '%.2f' % seating_category_association.try(:price).to_f
    end

    procs['old_discount'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      event_order_line_item_version = event_order_line_item.try(:versions).try(:last).try(:reify)
      event_order_line_item_version.present? ? ('%.2f' % event_order_line_item_version.try(:discount).to_f) : nil
    end

    procs['new_discount'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      '%.2f' % event_order_line_item.try(:discount).to_f
    end

    procs['difference_amount(paid/refunded)'] = Proc.new do |_registration|
      _registration_version = _registration.versions.last.try(:reify)
      seating_category_association = _registration.event_seating_category_association
      old_seating_category_association = _registration_version.try(:event_seating_category_association)
      is_category_changed = (old_seating_category_association.present? and seating_category_association.try(:id) != old_seating_category_association.try(:id))
      amount_diff = is_category_changed ? (old_seating_category_association.try(:price).to_f - seating_category_association.try(:price).to_f): nil
      paid_or_refunded = if amount_diff.present? then
                           if amount_diff < 0 then
                             ' - PAID'
                           else
                             amount_diff > 0 ? ' - REFUNDED' : nil
                           end
                         else
                           nil
                         end
      paid_or_refunded.present? ? (('%.2f' % amount_diff.to_f.abs) + paid_or_refunded) : nil
    end

    procs['total_tax'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % total_tax_detail[:total_tax_paid].to_f
    end

    procs['convienence_charges'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % total_tax_detail[:total_convenience_charges].to_f
    end

    procs['total_paid'] = Proc.new do |_registration|
      seating_category_association = _registration.event_seating_category_association
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % (seating_category_association.try(:price).to_f - event_order_line_item.try(:discount).to_f + total_tax_detail[:total_tax_paid].to_f + total_tax_detail[:total_convenience_charges].to_f)
    end

    procs['registration_status'] = Proc.new do |_registration|
      _registration.status.present? ? EventOrder.template_status_mapper[_registration.status.to_s] : 'Success'
    end

    procs['reg_ref_number'] = Proc.new do |_registration|
      event_order = _registration.event_order
      event_order.try(:reg_ref_number)
    end

    procs['registration_date'] = Proc.new do |_registration|
      _registration.try(:created_at).try(:strftime, ('%b %d, %Y'))
    end

    procs['event_name'] = Proc.new do |_registration|
      event = _registration.event
      event.try(:event_name)
    end

    procs['event_start_date'] = Proc.new do |_registration|
      event = _registration.event
      event.try(:event_start_date).try(:strftime, ('%b %d, %Y'))
    end

    procs['event_end_date'] = Proc.new do |_registration|
      event = _registration.event
      event.try(:event_end_date).try(:strftime, ('%b %d, %Y'))
    end

    procs['payment_status'] = Proc.new do |_registration|
      event_order = _registration.event_order
      event_order.try(:status)
    end

    procs['payment_method'] = Proc.new do |_registration|
      event_order = _registration.event_order
      event_order.try(:payment_method)
    end

    procs['registration_id'] = Proc.new do |_registration|
      _registration.id
    end

    procs['item_id'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      event_order_line_item.try(:id)
    end

    procs['forum_id'] = Proc.new do |_registration|
      _registration.try(:sadhak_profile).try(:active_club).try(:id)
    end

    procs['forum_name'] = Proc.new do |_registration|
      _registration.try(:sadhak_profile).try(:active_club).try(:name)
    end

    procs['medical_degree'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      medical_practitioners_profile = sadhak_profile.try(:medical_practitioners_profile)
      medical_practitioners_profile.try(:medical_degree)
    end

    procs['current_profession'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      medical_practitioners_profile = sadhak_profile.try(:medical_practitioners_profile)
      medical_practitioners_profile.try(:current_professional_role)
    end

    procs['work_environment'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      medical_practitioners_profile = sadhak_profile.try(:medical_practitioners_profile)
      medical_practitioners_profile.try(:work_enviroment)
    end

    procs['speciality_area'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      medical_practitioners_profile = sadhak_profile.try(:medical_practitioners_profile)
      medical_practitioner_speciality_area = medical_practitioners_profile.try(:medical_practitioner_speciality_area)
      medical_practitioner_speciality_area.present? ? medical_practitioner_speciality_area.try(:name) : medical_practitioners_profile.try(:other_speciality)
    end

    procs['bank_name'] = Proc.new do |_registration|
      dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).first
      dd_data.try(:bank_name)
    end

    procs['admin_notes'] = Proc.new do |_registration|
      dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).first
      dd_data.try(:additional_details)
    end

    procs['dd_date'] = Proc.new do |_registration|
      dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).first
      dd_data.try(:dd_date).try(:strftime, ('%b %d, %Y'))
    end

    procs['registered_by'] = Proc.new do |_registration|
      event_order = _registration.event_order
      if event_order.user_id.present?
        event_order.registration_center_user_id = _registration.event.get_registration_center_user_id(event_order.user_id)
        registration_center = event_order.registration_center
      end
      event_order.try(:user).try(:sadhak_profile).try(:syid).to_s + '-' + registration_center.try(:name).to_s
    end

    procs['is_forum_member'] = Proc.new do |_registration|
      _registration.try(:sadhak_profile).try(:active_club_ids).present? ? 'Yes' : 'No'
    end

    procs['is_forum_board_member'] = Proc.new do |_registration|
      _registration.try(:sadhak_profile).try(:sy_clubs).present? ? 'Yes' : 'No'
    end


    # Event Registration Report - Ends

    procs
  end

  def report_event_registration_tally
    procs = {}

    # Event Registration Tally Report - Starts

    # Create Tally Report
    # event_registration_tally_report_master = ReportMaster.find_or_create_by(report_name: 'event_registration_tally', required_params: ['event_id'])

    # columns = ["registration_number", "syid", "name", "category", "registration_date", "amount", "total_tax", "grand_total", "transaction_id", "cost_center_name"]

    # columns.each do |c|
    #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
    #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_tally_report_master.id, report_master_field_id: rmf.id)
    # end

    # event_registration_tally_report_master.reload.update_report_blocks


    # Start block for event_registration_tally
    procs['_start_block'] = Proc.new do |parent_task, params = {}|

      raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

      event = Event.preloaded_data.find_by_id(params[:event_id])

      raise 'Event cannot be blank.' unless event.present?

      # Assign default value to from and to
      from = params[:from].present? ? params[:from] : (Date.today - 10.years).to_s
      to = params[:to].present? ? params[:to] : (Date.today + 10.years).to_s

      if event.sy_event_company_id.present?
        event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', from, to).order('serial_number')
      else
        event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', from, to).order('event_order_line_item_id')
      end

      if params[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: params[:report_master_field_association_ids])
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: params[:report_master_id])
      end
      params[:batch_size] = (3e6 / (report_field_ass.size * 16)).to_i

      # Update file name in parent task config
      t_config = ActiveSupport::HashWithIndifferentAccess.new(parent_task.t_config)

      t_config[:file_name] = event.try(:event_name).truncate(40, omission: '... (continued)') + '_' + t_config[:file_name]

      parent_task.update_columns(t_config: t_config)

      parent_task.result = event_registrations.pluck(:id)
    end

    # Final block for event_registration_tally
    procs['_final_block'] = Proc.new do |sub_task, ids, opts = {}|

      raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

      if opts[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: opts[:report_master_field_association_ids]).sort_by(&:id)
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: opts[:report_master_id]).sort_by(&:id)
      end

      header = report_field_ass.collect{|rfa| rfa.report_master_field.field_name.upcase}
      rows = []

      includable_data = [{sadhak_profile: [{ address: [:db_city, :db_state, :db_country] }, {medical_practitioners_profile: [:medical_practitioner_speciality_area]}]}, {event_order: [:registration_center_user, :registration_center, :event_registrations, :versions]}, {event_order_line_item: [:versions]}, :event_seating_category_association, :seating_category, :user, :versions, {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {registration_centers: [:registration_center_users]}, :event_tax_type_associations, :tax_types]}, {sy_club_member: [:sy_club]}]

      event_registrations = EventRegistration.where(id: ids).includes(includable_data)

      event_registrations.each_with_index do |_registration, _index|
        row = []
        report_field_ass.each do |_report_field_ass|
          block = eval(_report_field_ass.proc_block.to_s)
          row.push(block.present? ? block.call(_registration) : nil)
        end
        rows.push(row)
      end

      file = GenerateExcel.generate(rows: rows, header: header, data_type: 'file')

      sub_task.result = {file: file, from: event_registrations.first.id, to: event_registrations.last.id, format: 'xls'}
    end

    procs['registration_number'] = Proc.new do |_registration|
      if _registration.try(:event).try(:sy_event_company_id).present? then
        _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil
      else
        _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil
        # Deprecated on request of sandeep
        # _registration.try(:event_order_line_item_id).present? ? _registration.event_order_line_item_id : nil
      end
    end

    procs['syid'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:syid)
    end

    procs['name'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:full_name)
    end

    procs['category'] = Proc.new do |_registration|
      seating_category = _registration.seating_category
      seating_category.try(:category_name)
    end

    procs['registration_date'] = Proc.new do |_registration|
      _registration.try(:created_at).try(:strftime, ('%b %d, %Y'))
    end

    procs['amount'] = Proc.new do |_registration|
      seating_category_association = _registration.event_seating_category_association
      '%.2f' % seating_category_association.try(:price).to_f
    end

    procs['total_tax'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % total_tax_detail[:total_tax_paid].to_f
    end

    procs['grand_total'] = Proc.new do |_registration|
      seating_category_association = _registration.event_seating_category_association
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % (seating_category_association.try(:price).to_f - event_order_line_item.try(:discount).to_f + total_tax_detail[:total_tax_paid].to_f + total_tax_detail[:total_convenience_charges].to_f)
    end

    procs['transaction_id'] = Proc.new do |_registration|
      event_order = _registration.event_order
      event_order.try(:transaction_id)
    end

    procs['cost_center_name'] = Proc.new do |_registration|
      _registration.event.try(:event_name_with_location).to_s + ' ' + _registration.event.try(:event_date).to_s
    end

    # Event Registration Tally Report - Ends

    procs
  end

  def report_event_registration_dd_cash_tally
    procs = {}

    # Event Registration Tally Report Cash DD - Starts

    # Create Cash DD Tally Report
    # event_registration_dd_cash_tally_report_master = ReportMaster.find_or_create_by(report_name: 'event_registration_dd_cash_tally', required_params: ['event_id'])

    # columns = ["registration_number", "syid", "name", "registration_date", "amount", "total_tax", "grand_total", "payment_type", "dd_number", "dd_date", "cost_center_name"]

    # columns.each do |c|
    #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
    #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_dd_cash_tally_report_master.id, report_master_field_id: rmf.id)
    # end

    # event_registration_dd_cash_tally_report_master.reload.update_report_blocks


    # Start block for event_registration_tally
    procs['_start_block'] = Proc.new do |parent_task, params = {}|

      raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

      event = Event.preloaded_data.find_by_id(params[:event_id])

      raise 'Event cannot be blank.' unless event.present?

      # Assign default value to from and to
      from = params[:from].present? ? params[:from] : (Date.today - 10.years).to_s
      to = params[:to].present? ? params[:to] : (Date.today + 10.years).to_s

      if event.sy_event_company_id.present?
        event_registrations = EventRegistration.joins(:event_order).where(event_registrations: {event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)}, event_orders: {payment_method: ['Cash Payment', 'Demand draft']}).where('event_registrations.created_at >= ? AND event_registrations.created_at <= ?', from, to).order('serial_number')
      else
        event_registrations = EventRegistration.joins(:event_order).where(event_registrations: {event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)}, event_orders: {payment_method: ['Cash Payment', 'Demand draft']}).where('event_registrations.created_at >= ? AND event_registrations.created_at <= ?', from, to).order('event_order_line_item_id')
      end

      if params[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: params[:report_master_field_association_ids])
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: params[:report_master_id])
      end
      params[:batch_size] = (3e6 / (report_field_ass.size * 16)).to_i

      # Update file name in parent task config
      t_config = ActiveSupport::HashWithIndifferentAccess.new(parent_task.t_config)

      t_config[:file_name] = event.try(:event_name).truncate(40, omission: '... (continued)') + '_' + t_config[:file_name]

      parent_task.update_columns(t_config: t_config)

      parent_task.result = event_registrations.pluck(:id)
    end

    # Final block for event_registration_tally
    procs['_final_block'] = Proc.new do |sub_task, ids, opts = {}|

      raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

      if opts[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: opts[:report_master_field_association_ids]).sort_by(&:id)
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: opts[:report_master_id]).sort_by(&:id)
      end

      header = report_field_ass.collect{|rfa| rfa.report_master_field.field_name.upcase}
      rows = []

      includable_data = [{sadhak_profile: [{ address: [:db_city, :db_state, :db_country] }, {medical_practitioners_profile: [:medical_practitioner_speciality_area]}]}, {event_order: [:registration_center_user, :registration_center, :event_registrations, :versions]}, {event_order_line_item: [:versions]}, :event_seating_category_association, :seating_category, :user, :versions, {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {registration_centers: [:registration_center_users]}, :event_tax_type_associations, :tax_types]}, {sy_club_member: [:sy_club]}]

      event_registrations = EventRegistration.where(id: ids).includes(includable_data)

      event_registrations.each_with_index do |_registration, _index|
        row = []
        report_field_ass.each do |_report_field_ass|
          block = eval(_report_field_ass.proc_block.to_s)
          row.push(block.present? ? block.call(_registration) : nil)
        end
        rows.push(row)
      end

      file = GenerateExcel.generate(rows: rows, header: header, data_type: 'file')

      sub_task.result = {file: file, from: event_registrations.first.id, to: event_registrations.last.id, format: 'xls'}
    end

    procs['registration_number'] = Proc.new do |_registration|
      if _registration.try(:event).try(:sy_event_company_id).present? then
        _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil
      else
        _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : nil
        #Deprecated on sandeep ji request.
        # _registration.try(:event_order_line_item_id).present? ? _registration.event_order_line_item_id : nil
      end
    end

    procs['syid'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:syid)
    end

    procs['name'] = Proc.new do |_registration|
      sadhak_profile = _registration.sadhak_profile
      sadhak_profile.try(:full_name)
    end

    procs['registration_date'] = Proc.new do |_registration|
      _registration.try(:created_at).try(:strftime, ('%b %d, %Y'))
    end

    procs['amount'] = Proc.new do |_registration|
      seating_category_association = _registration.event_seating_category_association
      '%.2f' % seating_category_association.try(:price).to_f
    end

    procs['total_tax'] = Proc.new do |_registration|
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % total_tax_detail[:total_tax_paid].to_f
    end

    procs['grand_total'] = Proc.new do |_registration|
      seating_category_association = _registration.event_seating_category_association
      event_order_line_item = _registration.event_order_line_item
      total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys
      '%.2f' % (seating_category_association.try(:price).to_f - event_order_line_item.try(:discount).to_f + total_tax_detail[:total_tax_paid].to_f + total_tax_detail[:total_convenience_charges].to_f)
    end

    procs['payment_type'] = Proc.new do |_registration|
      _registration.event_order.try(:payment_method).try(:titleize)
    end

    procs['dd_number'] = Proc.new do |_registration|
      dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).order(:id).last
      dd_data.try(:dd_number)
    end

    procs['dd_date'] = Proc.new do |_registration|
      dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).order(:id).last
      dd_data.try(:dd_date).try(:strftime, ('%b %d, %Y'))
    end

    procs['cost_center_name'] = Proc.new do |_registration|
      _registration.event.try(:event_name_with_location).to_s + ' ' + _registration.event.try(:event_date).to_s
    end

    # Event Registration Tally Report Cash DD - Ends

    procs
  end

  def report_photo_approval

    procs = {}

    # Start block for report_photo_approval
    procs['_start_block'] = Proc.new do |parent_task, params = {}|

      raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

      event = Event.find_by_id(params[:id])

      raise 'Event cannot be blank.' unless event.present?

      # Get sadhak Profiles
      sadhak_profiles = event.vaild_registered_sadhak_profiles.order(:id)

      if params[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: params[:report_master_field_association_ids])
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: params[:report_master_id])
      end
      params[:batch_size] = (3e6 / (report_field_ass.size * 16)).to_i

      # Update file name in parent task config
      t_config = ActiveSupport::HashWithIndifferentAccess.new(parent_task.t_config)

      t_config[:file_name] = event.try(:event_name) + '_' + t_config[:file_name]

      parent_task.update_columns(t_config: t_config)

      parent_task.result = sadhak_profiles.pluck(:id)
    end

    # Final block for event_registration_tally
    procs['_final_block'] = Proc.new do |sub_task, ids, opts = {}|

      raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

      if opts[:report_master_field_association_ids].present?
        report_field_ass = ReportMasterFieldAssociation.where(id: opts[:report_master_field_association_ids]).sort_by(&:id)
      else
        report_field_ass = ReportMasterFieldAssociation.where(report_master_id: opts[:report_master_id]).sort_by(&:id)
      end

      header = report_field_ass.collect{|rfa| rfa.report_master_field.field_name.upcase}
      rows = []

      includable_data = [{advance_profile: [:advance_profile_photograph, :advance_profile_identity_proof]}]

      sadhak_profiles = SadhakProfile.where(id: ids).includes(includable_data).order(:id)

      sadhak_profiles.each_with_index do |_sadhak_profile, _index|
        row = []
        report_field_ass.each do |_report_field_ass|
          block = eval(_report_field_ass.proc_block.to_s)
          row.push(block.present? ? block.call(_sadhak_profile) : nil)
        end
        rows.push(row)
      end

      t_config = ActiveSupport::HashWithIndifferentAccess.new(sub_task.t_config)

      options = {
        rows: rows,
        header: header,
        data_type: t_config[:sync] ? nil : 'file'
      }

      file = if opts[:type] == 'csv' then
        GenerateCsv.generate(options)
      else
        GenerateExcel.generate(options)
      end

      sub_task.result = {file: file, from: sadhak_profiles.first.id, to: sadhak_profiles.last.id, format: 'xls'}
    end

    procs['syid'] = Proc.new do |_sadhak_profile|
      _sadhak_profile.try(:syid)
    end

    procs['name'] = Proc.new do |_sadhak_profile|
      _sadhak_profile.try(:full_name)
    end

    # procs['photo'] = Proc.new do |_sadhak_profile|
    #   _sadhak_profile.try(:advance_profile).try(:advance_profile_photograph).try(:s3_url)
    # end

    # procs['photo_id'] = Proc.new do |_sadhak_profile|
    #   _sadhak_profile.try(:advance_profile).try(:advance_profile_identity_proof).try(:s3_url)
    # end

    procs['approval_status'] = Proc.new do |_sadhak_profile|
      if _sadhak_profile.present? && _sadhak_profile.advance_profile.present? && _sadhak_profile.advance_profile.advance_profile_photograph.present? && _sadhak_profile.advance_profile.advance_profile_identity_proof.present?

        if _sadhak_profile.pp_pending? || _sadhak_profile.pi_pending?
          'Pending'
        elsif _sadhak_profile.pp_success? && _sadhak_profile.pi_success?
          'Approved'
        elsif _sadhak_profile.pp_rejected? && _sadhak_profile.pi_rejected?
          'Rejected'
        else
          'Not Available'
        end

      else
        'Not Available'
      end
    end

    procs['status_changed_by_syid'] = Proc.new do |_sadhak_profile|
      if _sadhak_profile.present? && _sadhak_profile.advance_profile.present? && _sadhak_profile.advance_profile.advance_profile_photograph.present? && _sadhak_profile.advance_profile.advance_profile_identity_proof.present?

        if _sadhak_profile.pp_success? && _sadhak_profile.pi_success? || _sadhak_profile.pp_rejected? && _sadhak_profile.pi_rejected?
          change_log = _sadhak_profile.shivyog_change_logs.last
          change_log.try(:creator).try(:sadhak_profile).try(:syid)
        else
          nil
        end
      else
        nil
      end
    end

    procs['status_changed_by_name'] = Proc.new do |_sadhak_profile|
      if _sadhak_profile.present? && _sadhak_profile.advance_profile.present? && _sadhak_profile.advance_profile.advance_profile_photograph.present? && _sadhak_profile.advance_profile.advance_profile_identity_proof.present?

        if _sadhak_profile.pp_success? && _sadhak_profile.pi_success? || _sadhak_profile.pp_rejected? && _sadhak_profile.pi_rejected?
          change_log = _sadhak_profile.shivyog_change_logs.last
          change_log.try(:creator).try(:sadhak_profile).try(:full_name)
        else
          nil
        end
      else
        nil
      end
    end

    procs['status_changed_date'] = Proc.new do |_sadhak_profile|
      if _sadhak_profile.present? && _sadhak_profile.advance_profile.present? && _sadhak_profile.advance_profile.advance_profile_photograph.present? && _sadhak_profile.advance_profile.advance_profile_identity_proof.present?

        if _sadhak_profile.pp_success? && _sadhak_profile.pi_success? || _sadhak_profile.pp_rejected? && _sadhak_profile.pi_rejected?
          change_log = _sadhak_profile.shivyog_change_logs.last
          change_log.try(:created_at).try(:strftime, '%b %d %Y')
        else
          nil
        end
      else
        nil
      end
    end

    procs['status_changed_reasons'] = Proc.new do |_sadhak_profile|
      if _sadhak_profile.present? && _sadhak_profile.advance_profile.present? && _sadhak_profile.advance_profile.advance_profile_photograph.present? && _sadhak_profile.advance_profile.advance_profile_identity_proof.present?

        if _sadhak_profile.pp_rejected? && _sadhak_profile.pi_rejected?
          change_log = _sadhak_profile.shivyog_change_logs.last
          change_log.try(:description)
        else
          nil
        end
      else
        nil
      end
    end

    procs
  end
end
