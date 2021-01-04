module Utilities
  class MaskEmail

    def self.call(user_email)
      email = ''
      if user_email.present?
        split_email = user_email.to_s.split('@')
        email_text = split_email[0]
        if email_text.present? and email_text.length > 2
          temp = '*' * (email_text.length-2)
          email = email_text[0].to_s + temp + email_text[email_text.length-1].to_s + '@' + split_email[1].to_s
        else
          email = '*****************@' + split_email[1].to_s
        end
      end
      email
    end
  end
end
