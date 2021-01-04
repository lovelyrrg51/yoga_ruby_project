namespace :voucher do

  desc 'To send invoice vouchers for events that overed.'
  task :send_invoices, [:event_ids] => :environment do |t, args|

    event_ids = args[:event_ids].present? ? args[:event_ids].split(RAKE_TASK_ARGS_SEPERATOR) : Event.where(event_end_date: Date.today - 1.day).where.not(sy_event_company_id: nil).pluck(:id)

    Event.where(id: event_ids).find_each(batch_size: 1) do |event|

      event.valid_event_registrations.find_each(batch_size: 1) do |event_registration|

        next unless event_registration.sy_event_company.present? && !event_registration.invoice_voucher.present? && event_registration.receipt_voucher.present?

        begin

          ActiveRecord::Base.transaction do

            last_invoice_voucher_number = event_registration.sy_event_company.last_invoice_voucher_number + 1

            event_registration.vouchers.build(voucher_number: ("%06d" % last_invoice_voucher_number), voucher_type: Voucher.voucher_types[:invoice]).save!
            event_registration.sy_event_company.update_columns(last_invoice_voucher_number: last_invoice_voucher_number)

            event_registration.reload

            file_name = "invoice-voucher-#{event_registration.invoice_voucher.voucher_number}-#{event_registration.event_order.reg_ref_number}-#{event_registration.id}.pdf"

            voucher_data = event_registration.generate_invoice_data

            detail = ((event_registration.event_order.try(:transaction_logs).try(:pay).try(:success).try(:first).try(:request_params).try(:deep_symbolize_keys) || {})[:details] || []).find{|f| f[:discounted_line_item_id].to_i == event_registration.event_order_line_item_id} || {}

            voucher_data[:discount] = detail[:discount].to_f.round(2)

            voucher_data[:net_fee] = voucher_data[:basic_fee] - voucher_data[:discount]

            taxable_amount = voucher_data[:net_fee].to_f.round(2)

            taxes = []

            (event_registration.event_order_line_item.tax_types || []).each do |tax_association|
              tax_association = tax_association.deep_symbolize_keys
              taxes.push({tax_type_name: tax_association[:tax_type_name], percent: tax_association[:percent], tax_amount: ((taxable_amount * tax_association[:percent].to_f)/100).round(2)})
            end

            # Assign taxes
            voucher_data[:taxes] = taxes

            # Condition: if not a delhi sadhak && (clp || live) => IGST else => CGST
            if !voucher_data[:sadhak_state].include?(STATE_DELHI) && ((event_registration.event.graced_by == 'Subtle presence of Babaji') || event_registration.event.get_clp_detail[:is_clp_event])

              voucher_data[:cgst] = {}

              voucher_data[:sgst] = {}

              voucher_data[:igst] = {tax_type_name: 'IGST', percent: '18', tax_amount: is_tax_applicable ? ((taxable_amount * 18)/100).round(2) : 0}

            else

              voucher_data[:cgst] = {tax_type_name: 'CGST', percent: '9', tax_amount: is_tax_applicable ? ((taxable_amount * 9)/100).round(2) : 0}

              voucher_data[:sgst] = {tax_type_name: 'SGST', percent: '9', tax_amount: is_tax_applicable ? ((taxable_amount * 9)/100).round(2) : 0}

              voucher_data[:igst] = {}

            end

            voucher_data[:tax_applicable] = taxes.collect{|tax| tax[:tax_amount].to_f}.sum

            voucher_data[:paid_amount_with_all_charges] = (taxable_amount + voucher_data[:tax_applicable])

            voucher_data[:convienence_charges] = voucher_data[:gateway_config].try(:tax_amount).present? ? (voucher_data[:paid_amount_with_all_charges] * voucher_data[:gateway_config].try(:tax_amount).to_f / 100).round(2) : 0.00

            begin
              if event_registration.sy_event_company.try(:automatic_invoice)
                receipents = [event_registration.sadhak_profile.try(:email), event_registration.event_order.guest_email].extract_valid_emails
                file = event_registration.generate_pdf(:pdf, voucher_data, 'invoices/invoice_voucher')
                attachments = Hash[file_name, file]
                from = GetSenderEmail.call(event_registration.event)
                ApplicationMailer.send_email(from: from, recipients: receipents, subject: "Registration Invoice Receipt for event #{event_registration.event.try(:event_name).try(:titleize)} - #{event_registration.event_order.reg_ref_number}", template: '', attachments: attachments).deliver if receipents.size.nonzero?
              end
            rescue Exception => e
              Rails.logger.info("Error ocuured while sending email: #{e.message}, Rake Task (VOUCHER::SEND_INVOICES): Registration Id: #{event_registration.id}")
            end

            blob = generate_pdf(:file, voucher_data, 'invoices/invoice_voucher')
            Attachment.upload_file(file_name: file_name, content: blob, is_secure: false, bucket_name: ENV['ATTACHMENT_BUCKET'], attachable_id: event_registration.invoice_voucher.id, attachable_type: event_registration.invoice_voucher.class.to_s, file_type: 'application/pdf', prefix: "#{ENV['ENVIRONMENT']}/registration_vouchers/#{event_registration.event_id}/#{event_registration.event_order.reg_ref_number}")
            File.delete(blob) if File.exist?(blob)

          end

        rescue => e
          Rollbar.error(e)
        end

      end

    end

  end

  # "1111,1112,1113,1115,1116,1117,1118,1119,1128,1129,1134,1135,1136,1137,1138,1140,1141,1142,1143,1144,1146,1158,1165,1166,1177,1181,1182,1190,1191,1192,1194,1195,1196,1197,1204,1212,1226,1227,1231,1232,1239,1068,1131,1183,1132,1145,1217,1219,1222,1224,1228,1249,1223,1225,1256,1279,1282,1283,1284,1289,1292,1297,1305,1306,1344,1345,1346,1347,1285,1286,1287,1301,1317,1318,1319,1320,1350,1351,1356,1359,1363,1059,1058,1034,1361,1373,1374,1375,1376,1377,1378,1035,1027,1030,1026,1031,1046,1032,1047,1048,1033,1214,1215,1028,1029,1060,1061,1399,1402,1404,1406,1062,1400,1401,1403,1405,1036,1050,1037,1049,1213,1038,1039,1040,1041,1042,1043,1044,1045"
  # rake voucher:all["1111"]
  desc 'To send invoice vouchers for events that overed.'
  task :all, [:event_ids] => :environment do |t, args|

    event_ids = args[:event_ids].try(:split, RAKE_TASK_ARGS_SEPERATOR)

    raise 'Please input some event ids' && exit unless event_ids.present?

    tax_type_ids = TaxType.where('created_at >= ?', '2017-07-01').pluck(:id)

    Event.where(id: event_ids).find_each(batch_size: 1) do |event|

      event.event_registrations.find_each(batch_size: 1) do |event_registration|

        print "#{event_registration.id}-"

        next unless event_registration.sy_event_company.present?

        next if (event_registration.event_order_line_item.tax_types.collect(&:tax_type_id) & tax_type_ids).size.zero?

        save_path = "#{Rails.root}/extra/registration_vouchers/#{event_registration.event_id}/#{event_registration.event_order.reg_ref_number}"

        FileUtils.mkdir_p(save_path) unless Dir.exists?(save_path)

        begin

          ActiveRecord::Base.transaction do

            sy_event_company = event_registration.event.sy_event_company

            # Receipt Voucher
            unless event_registration.receipt_voucher.present?

              event_registration.vouchers.build(voucher_number: ("%06d" % (sy_event_company.last_receipt_voucher_number + 1))).save!

              sy_event_company.update_columns(last_receipt_voucher_number: sy_event_company.last_receipt_voucher_number + 1)

              event_registration.update_columns(sy_event_company_id: sy_event_company.id) unless event_registration.sy_event_company_id == sy_event_company.id

              sy_event_company = sy_event_company.reload

              event_registration = event_registration.reload

            end

            file_name = "receipt-voucher-#{event_registration.receipt_voucher.voucher_number}-#{event_registration.event_order.reg_ref_number}-#{event_registration.id}.pdf"

            blob = event_registration.generate_pdf(:file, event_registration.generate_invoice_data, 'invoices/receipt_voucher.html.erb')

            FileUtils.mv(blob.path, "#{save_path}/#{file_name}")

            raise "No receipt voucher found: #{event_registration}" unless event_registration.receipt_voucher.present?

            unless event_registration.cancelled_refunded?

              unless event_registration.invoice_voucher.present?

                last_invoice_voucher_number = sy_event_company.last_invoice_voucher_number + 1

                event_registration.vouchers.build(voucher_number: ("%06d" % last_invoice_voucher_number), voucher_type: Voucher.voucher_types[:invoice]).save!

                sy_event_company.update_columns(last_invoice_voucher_number: last_invoice_voucher_number)

                event_registration.update_columns(sy_event_company_id: sy_event_company.id) unless event_registration.sy_event_company_id == sy_event_company.id

                sy_event_company = sy_event_company.reload

                event_registration = event_registration.reload

              end

              voucher_data = event_registration.generate_invoice_data

              file_name = "invoice-voucher-#{event_registration.invoice_voucher.voucher_number}-#{event_registration.event_order.reg_ref_number}-#{event_registration.id}.pdf"

              detail = ((event_registration.event_order.try(:transaction_logs).try(:pay).try(:success).try(:first).try(:request_params).try(:deep_symbolize_keys) || {})[:details] || []).find{|f| f[:discounted_line_item_id].to_i == event_registration.event_order_line_item_id} || {}

              voucher_data[:discount] = detail[:discount].to_f.round(2)

              voucher_data[:net_fee] = voucher_data[:basic_fee] - voucher_data[:discount]

              taxable_amount = voucher_data[:net_fee].to_f.round(2)

              taxes = []

              (event_registration.event_order_line_item.tax_types || []).each do |tax_association|
                tax_association = tax_association.deep_symbolize_keys
                taxes.push({tax_type_name: tax_association[:tax_type_name], percent: tax_association[:percent], tax_amount: ((taxable_amount * tax_association[:percent].to_f)/100).round(2)})
              end

              voucher_data[:tax_applicable] = taxes.collect{|t| t[:tax_amount].to_f}.sum

              is_tax_applicable = voucher_data[:tax_applicable].nonzero?

              # Assign taxes
              voucher_data[:taxes] = taxes

              # Condition: if not a delhi sadhak && (clp || live) => IGST else => CGST
              if !voucher_data[:sadhak_state].include?(STATE_DELHI) && ((event_registration.event.graced_by == 'Subtle presence of Babaji') || event_registration.event.get_clp_detail[:is_clp_event])

                voucher_data[:cgst] = {}

                voucher_data[:sgst] = {}

                voucher_data[:igst] = {tax_type_name: 'IGST', percent: '18', tax_amount: is_tax_applicable ? ((taxable_amount * 18)/100).round(2) : 0}

              else

                voucher_data[:cgst] = {tax_type_name: 'CGST', percent: '9', tax_amount: is_tax_applicable ? ((taxable_amount * 9)/100).round(2) : 0}

                voucher_data[:sgst] = {tax_type_name: 'SGST', percent: '9', tax_amount: is_tax_applicable ? ((taxable_amount * 9)/100).round(2) : 0}

                voucher_data[:igst] = {}

              end

              voucher_data[:paid_amount_with_all_charges] = (taxable_amount + voucher_data[:tax_applicable])

              voucher_data[:convienence_charges] = voucher_data[:gateway_config].try(:tax_amount).present? ? (voucher_data[:paid_amount_with_all_charges] * voucher_data[:gateway_config].try(:tax_amount).to_f / 100).round(2) : 0.00

              blob = generate_pdf(:file, voucher_data, 'invoices/invoice_voucher')

              FileUtils.mv(blob.path, "#{save_path}/#{file_name}")

            else

              unless event_registration.refund_voucher.present?

                last_refund_voucher_number = sy_event_company.last_refund_voucher_number + 1

                event_registration.vouchers.build(voucher_number: ("%06d" % last_refund_voucher_number), voucher_type: Voucher.voucher_types[:refund]).save!

                sy_event_company.update_columns(last_refund_voucher_number: last_refund_voucher_number)

                sy_event_company = sy_event_company.reload

                event_registration = event_registration.reload

              end

              # Refund Voucher
              payment_refund = event_registration.payment_refund_line_item.payment_refund

              gateways = []

              refund_txns = payment_refund.event_order.transaction_logs.refund.select{|transaction_log| transaction_log.other_detail['payment_refund_id'] == payment_refund.id }

              if refund_txns.any?
                gateways = TransferredEventOrder.gateways.select{|g| refund_txns.collect(&:gateway_name).include?(g[:symbol]) }
              else
                payment_methods = payment_refund.event_order.transaction_logs.refund.last(1).collect{|transaction_log| transaction_log.other_detail['method'] }
                gateways = TransferredEventOrder.gateways.select{|g| payment_methods.include?(g[:payment_method]) }
              end

              mode_of_refund = gateways.collect{|g| g[:gateway_type] == 'online' ? 'Online' : g[:payment_method] }.collect(&:titleize).uniq.join('-')

              invoice = {}

              _event = payment_refund.event

              _event.event_cancellation_plan_id = payment_refund.event_cancellation_plan_id

              invoice[:mode_of_refund] = mode_of_refund

              invoice[:refunded_amount] = event_registration.payment_refund_line_item.event_order_line_item.price.to_f - event_registration.payment_refund_line_item.event_order_line_item.discount.to_f

              def _event.cancellation_charges_by_policy(event_order_line_item_ids)

                raise SyException, "Please provide event_order_line_item_ids. method cancellation_charges_by_policy." if event_order_line_item_ids.empty?

                # Compute days difference between event start date and today, i.e used to compute best plan item
                days_diff = (event_start_date - Date.today).to_i

                # Return zero cancellation charges as there is no policy attached
                return 0.0 unless event_cancellation_plan_id.present?

                # Collect plan items attached to cancellation plan
                plan_items = event_cancellation_plan.event_cancellation_plan_items.order(:days_before)

                # Raise error if no plan item found
                return 0.0 unless plan_items.present?

                best_plan_item = plan_items.where("days_before <= ?", days_diff).last

                best_plan_item = plan_items.first unless best_plan_item.present?

                return 0.0 unless best_plan_item.present?

                if best_plan_item.try(:amount_type) == "fixed"
                  result = event_order_line_item_ids.count * best_plan_item.amount

                elsif best_plan_item.try(:amount_type) == "percentage"
                  result = EventOrderLineItem.where(id: event_order_line_item_ids).includes(:event_seating_category_association).collect{|item| item.try(:event_seating_category_association).try(:price).to_f - item.try(:discount).to_f + (item.total_tax_detail || {})['total_tax_paid'].to_f }.sum * best_plan_item.amount / 100

                else
                  result = 9999999
                end

                result.to_f.round(2)
              end

              invoice[:cancellation_charges] = _event.cancellation_charges_by_policy([event_registration.payment_refund_line_item.event_order_line_item_id])

              invoice[:recieved_amount] = invoice[:refunded_amount] - invoice[:cancellation_charges]

              file_name = "refund-voucher-#{event_registration.refund_voucher.voucher_number}-#{event_registration.event_order.reg_ref_number}-#{event_registration.id}.pdf"

              invoice = event_registration.generate_invoice_data.merge(invoice).with_indifferent_access

              blob = event_registration.generate_pdf(:file, invoice, 'invoices/refund_voucher')

              FileUtils.mv(blob.path, "#{save_path}/#{file_name}")

            end
          end

        rescue => e
          Rollbar.error(e)
        end

      end

    end

  end

end
