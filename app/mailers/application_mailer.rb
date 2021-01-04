class ApplicationMailer < ActionMailer::Base
  default from: 'support@absclp.com'
  layout 'mailer'

  def send_email(options = {})
    if options.present?
      @options = options
      @to = (options[:recipients] || []).extract_valid_emails
      @cc = (options[:cc] || []).extract_valid_emails
      @bcc = (options[:bcc] || []).extract_valid_emails
      @template = options[:template] || ''
      @subject = options[:subject] || 'Default email from Shivyog.'
      @from = options[:from]
      @reply_to = options[:reply_to]

      # @cc += ['prince@metadesignsolutions.in'] if %w(development testing).include?(ENV['ENVIRONMENT'])
      # @cc += %w(victor.sen@metadesignsolutions.com.au) if ENV['ENVIRONMENT'] == 'testing'

      (@options[:attachments] || {}).each do |attachment_k, attachment_v|
        attachments["#{attachment_k}"] = attachment_v
      end

      # @from = 'support@absclp.com'

      mail_hash = {from: @from, to: @to, cc: @cc, bcc: @bcc, subject: @subject, reply_to: @reply_to}

      %w(from reply_to).each do |ignore|
        mail_hash.delete(ignore.to_sym) unless mail_hash[ignore.to_sym].present?
      end

      mail(mail_hash) do |format|
        format.html { render @template } if @template.present?
        format.text { render text: 'Shivyog.' } unless @template.present?
      end
    end
  end
  
end
