module ApplicationHelper

  def current_sadhak_profile
    current_user.try(:sadhak_profile)
  end

  # Method used to show upcoming events in footer partial
  def upcoming_events
    [] || Event.where('event_start_date > :date AND event_end_date > :date AND status = :status', {date: Time.now.strftime('%Y-%m-%d'), status: Event.statuses.ready}).limit(3)
  end

  def url_contains?(sub_path)
    request.fullpath.split('/').include? sub_path
  end

  def options_for_select_graced_by
    ["Ishan ji","Baba ji","Subtle presence of Babaji"]
  end

  def options_for_select_payment_category
    [["Free", "free"],["Paid" , "paid"]]
  end

  def files_in_dir(path)
    file_names = Dir.entries(path) - [".", ".."]
    file_names.map do |file|
      file.sub!("_", '') if file[0] == "_"
      file
    end
  end

  def preview_or_default_image_for_file(file_obj = nil)
    return "nophoto.jpg" if file_obj.nil?

    file_extension = file_obj.try(:model).try(:s3_url).present? ? (File.extname file_obj.try(:model).try(:s3_path)) : File.extname(file_obj.file.path)
    get_preview_or_default_image_for_file({ file_obj: file_obj, file_extension: file_extension })
  end

  def filename(file_obj)
    return nil unless file_obj.present?
    file_obj.file.filename
  end

  def format_date(date)
    date = Date.parse(date.to_s) rescue nil
    return nil unless date.present?
    date.strftime('%b %d, %Y')
  end

  def get_current_user_email
    @current_user_email ||= if current_user.try(:sadhak_profile).try(:email).try(:is_valid_email?)
      current_user.try(:sadhak_profile).try(:email)
    elsif current_user.try(:email).try(:is_valid_email?)
      current_user.try(:email)
    else
      nil
    end
  end

  def user_search_by_options
    [["Search By First Name", "first_name"], ["Search By Mobile number", "mobile"], ["Search By Date of Birth", "date_of_birth"]]
  end

  def is_header_footer_hidden?
    return false if %w(comfy/cms/content comfy/blog/posts).include?(params[:controller])
    devise_controller? ||
      current_page?(controller: 'sadhak_profiles', action: 'sadhak_profile_token_verification') ||
      current_page?(controller: 'users', action: 'user_confirm_verification_code') ||
      current_page?(controller: 'users', action: 'forgot_password') ||
      params[:controller] == 'terms_and_conditions'
  end

  def current_action?(controller: 'default', action: 'default')
    (controller == params[:controller]) and (action == params[:action])
  end

  def encrypted_email(email = "")
    return "" unless email.present?
    str = email[1,email.index("@")-2]
    email.sub(str,(["*"]*str.length).join(""))
  end

  def encrypted_mobile(mobile = "")
    return "" unless mobile.present?
    str = mobile.to_s[4..-1]
    mobile.sub(str,(["*"]*str.length).join(""))
  end

  def custom_page_entries_info(collection)

    if collection.present?

      if collection.total_pages < 2
        case collection.size
          when 0; %{Showing 0 of 0}
          else;   %{Showing 1 of %d} % [
            collection.total_pages
          ]
        end
      else
        %{Showing %d of %d} % [
            params[:page] || 1,
            collection.total_pages
          ]
      end

    end

  end

  def is_event_running?(event)

    is_event_running = (event.end_date_ignored? || (event.event_end_date.present? && Date.today <= event.event_end_date))
    is_admin = (current_user.present? and (current_user.super_admin? or current_user.event_admin? or current_user.india_admin?))
    is_rc = current_user.try(:rc, event)
    is_admin || is_rc || (is_event_running and (event.test_registration? || event.ready?) and (event_online_payment_gatways(event).size > 0 || event_offline_payment_gateways(event).size > 0 || event.free?) and event.event_seating_category_associations.present?)

  end

  def event_online_payment_gatways(event)

    gateways = []

    event.event_payment_gateway_associations.each do |ga|

      if ga.payment_end_date and ga.payment_start_date and Date.today >= ga.payment_start_date and Date.today <= ga.payment_end_date and ga.payment_gateway.try(:payment_gateway_type).try(:name) != 'sydd'
        gateway = TransferredEventOrder.gateways.find{|g| g[:config_model] == ga.payment_gateway.try(:payment_gateway_type).try(:relation_name)}

        next unless gateway.present? and ga.payment_gateway.try(:payment_gateway_type).try(:name).present?

        gateways << {
          gateway_name: ga.payment_gateway.try(:payment_gateway_type).try(:name),
          gateway_alias_name: ga.try(:payment_gateway).try(ga.try(:payment_gateway).try(:payment_gateway_type).try(:relation_name)).try(:alias_name),
          gateway_detail: gateway,
          partial_path: "#{gateway[:model].underscore.pluralize}/custom",
          gateway_association: ga
        }
      end
    end

    gateways

  end

  def event_offline_payment_gateways(event)

    gateways = []

    rc = current_user.try(:rc, event)

    event.event_payment_gateway_associations.each do |ga|

      if ga.payment_end_date and ga.payment_start_date and Date.today >= ga.payment_start_date and Date.today <= ga.payment_end_date and ga.payment_gateway.try(:payment_gateway_type).try(:name) == 'sydd' and current_user.try(:india_admin?) || rc.present?

        gateway = TransferredEventOrder.gateways.find{|g| g[:config_model] == ga.payment_gateway.try(:payment_gateway_type).try(:relation_name)}

        next unless gateway.present? and ga.payment_gateway.try(:payment_gateway_type).try(:name).present?

        gateways << {
          gateway_name: ga.payment_gateway.try(:payment_gateway_type).try(:name),
          gateway_alias_name: gateway[:payment_method],
          gateway_detail: gateway,
          partial_path: "#{gateway[:model].underscore.pluralize}/custom",
          gateway_association: ga
        }
      end
    end

    if current_user.try(:super_admin?) || current_user.try(:event_admin?) || rc.try(:is_cash_allowed)

      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == 'cash'}

      gateways << {
        gateway_name: gateway[:symbol],
        gateway_alias_name: gateway[:symbol].try(:titleize),
        gateway_detail: gateway,
        partial_path: "#{gateway[:model].underscore.pluralize}/custom",
        gateway_association: nil
      }
    end

    gateways

  end

  def sadhak_generate_card_list

    if current_sadhak_profile.present?
      return @sadhak_generate_card_list if @sadhak_generate_card_list.present?
      event_ids = GlobalPreference.where(key: %w(india_clp_events global_clp_events)).collect{|gp| gp.try(:val).to_s.split(',')}.flatten
      sadhak_upcoming_event_registrations = current_sadhak_profile.event_registrations.joins(:event).where('event_registrations.status IN (?) AND events.event_start_date >= ? AND events.id NOT IN (?) AND events.shivir_card_enabled IS true', EventRegistration.valid_registration_statuses, (Date.today - 1.day), event_ids).includes(:event, :event_order)

      @sadhak_generate_card_list = [].tap do |item|

        (sadhak_upcoming_event_registrations || []).each do |er|

          item << { event_name: er.event.try(:event_name), reg_ref_number: er.event_order.try(:reg_ref_number) }

        end
      end
    end
  end

  def set_cookie(key = nil, value = nil, expiry = 1.day)
    return nil unless (value.present? && key.present?)
    cookies.encrypted[key.encrypt] = { value: value, expires: expiry.from_now }
  end

  def get_cookie(key)
    return nil unless (key.present? || cookies.encrypted[key.encrypt].present?)

    begin
      ActiveSupport::JSON.decode(cookies.encrypted[key.encrypt])
    rescue
      cookies.encrypted[key.encrypt]
    end
  end

  def has_asset?(asset = nil)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? asset
    else
      Rails.application.assets_manifest.assets[asset].present?
    end
  end

  def get_preview_or_default_image_for_file(file = {})
    file_obj = file[:file_obj]
    file_extension = file[:file_extension] || (file[:file_url].present? ? (File.extname file[:file_url]) : "")
    case file_extension.downcase
    when '.jpg', '.jpeg' , '.png'
      file_obj.try(:model).try(:thumb_url) || file_obj.try(:model).try(:s3_url) || file_obj.try(:url) || file[:file_url] || 'nophoto.jpg'
    when '.doc', '.docx'
      'DOC.png'
    when '.xls', '.xlsx'
      'XLS.png'
    when '.pdf'
      'PDF.png'
    else
      'nophoto.jpg'
    end

  end

  def sadhak_details(id)

    if id.present?
      syid = "sy#{id[/-?\d+/].to_i}".upcase
      sadhak_profile = SadhakProfile.find_by_syid(syid)
    end

  end

  def sadhak_photo_approval_events
    return @sadhak_photo_approval_events if @sadhak_photo_approval_events.present?
    role_dependable_ids = current_user.role_dependencies.includes({user_role: [:role]}).where(roles: {name: 'photo_approval_user'}, role_dependencies: {role_dependable_type: 'Event'}).select{|role_dependency|
        !role_dependency.is_restriction || (role_dependency.start_date..role_dependency.end_date).include?(Date.today)}.collect{|role_dependency| role_dependency.role_dependable}
    @sadhak_photo_approval_events = Event.where(id: role_dependable_ids)
  end

  def current_sadhak_profile_registered_upcoming_events
    @current_sadhak_profile_registered_upcoming_events ||= current_sadhak_profile.valid_event_registrations.joins(:event_order, :event)
    .where("events.event_start_date > :current_date AND events.event_end_date > :current_date", { current_date: Time.now.strftime('%Y-%m-%d') })
    .where("events.id NOT IN (?)", Event.clp_event_ids)
    .pluck("events.event_name", "event_orders.reg_ref_number")
  end

  def current_sadhak_profile_registered_ongoing_events
    @current_sadhak_profile_registered_ongoing_events ||= current_sadhak_profile.valid_event_registrations.joins(:event_order, :event)
    .where("events.event_start_date <= :current_date AND events.event_end_date >= :current_date", { current_date: Time.now.strftime('%Y-%m-%d') })
    .where("events.id NOT IN (?)", Event.clp_event_ids)
    .pluck("events.event_name", "event_orders.reg_ref_number")
  end
  def photo_approval_statuses
    statuses = SadhakProfile.ui_photo_approval_statuses.collect do |k,v|
      k = (k == 'approve' ? (k + 'd') : (k == 'rejected' ? k + 'ed' : k))
      [k.humanize, v]
    end
  end

  def get_status_color(status)
    if status == 'success' || status == 'transferred' || status == 'updated' || status == 'upgraded' || status == 'renewed' || status == 'approve'
      'success'
    elsif status == 'cancelled' || status == 'cancelled_refunded' || status == 'cancelled_refund_pending' || status == 'expired' || status == 'downgraded' || status == 'failure' || status == 'rejected'
      'danger'
    else
      'default'
    end
  end

  def bootstrap_class_for_flash(flash_type)
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end
  def get_status_color(status)
    if status == 'success' || status == 'transferred' || status == 'updated' || status == 'upgraded' || status == 'renewed' || status == 'approve'
      'success'
    elsif status == 'cancelled' || status == 'cancelled_refunded' || status == 'cancelled_refund_pending' || status == 'expired' || status == 'downgraded' || status == 'failure' || status == 'rejected'
      'danger'
    else
      'default'
    end
  end

  def top_menu name, &block
    tag.li do
      tag.a(name, href: '#!') +
      tag.div(class: %w[wsmegamenu onefourthmenu clearfix]) do
        tag.div class: 'container-fluid' do
          tag.div class: 'row' do
            tag.ul class: %w[col-lg-12 col-md-12 col-xs-12 link-list] do
              yield block
            end
          end
        end
      end
    end
  end

  def menu_link_to name, path, options = {}
    tag.li do
      link_to path, options do
        tag.i(class: %w[fa fa-arrow-circle-right]) + tag.span(name)
      end
    end
  end

  def shivyog_video_tag youtube_id:, image:, border: false, caption: '', sub_caption: ''
    html = ''
    a_options = {
      href: "Javascript: void(0);",
      class: %w[js-video-popup],
      data: {
        toggle: "modal",
        src: "https://www.youtube.com/embed/#{youtube_id}",
        target: "#myModal"
      }
    }
    image_classes = border ? %w[img-fluid] : %w[img-fluid img-no-border]

    html << tag.div(class: %w[shivyog_video_img]) do
      tag.a(a_options) do
        image_tag image, class: image_classes
      end
    end

    if caption.present?
      html << tag.div(class: %w[video_caption red-text]) do
        tag.strong caption
      end
    end

    if sub_caption.present?
      html << tag.div(sub_caption, class: %w[video_sub_caption])
    end

    html.html_safe
  end

  def get_ref_number(ref)
    ref.event_registrations.where(sadhak_profile_id: current_user.sadhak_profile.id).first.event_order.reg_ref_number if ref.event_registrations.any?
  end

  def get_event_order(ref)
    EventOrder.find_by(reg_ref_number: ref)
  end
end
