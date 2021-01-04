module Api::V1
  class InboxController < BaseController
    # include Mandrill::Rails::WebHookProcessor
  
    def handle_inbound(event_payload)
      logger.info event_payload["msg"]
      logger.info event_payload["event"]
      logger.info event_payload["ts"]
      logger.info event_payload["msg"]["email"]
      logger.info event_payload["msg"]["from_email"]
      logger.info event_payload.message_id
      logger.info event_payload.user_email
      logger.info event_payload.references
      logger.info event_payload.recipients
      logger.info event_payload.recipient_emails
  
      logger.info event_payload["msg"]["raw_msg"]
      logger.info event_payload["msg"]["html"]
      logger.info event_payload["msg"]["subject"]
      logger.info event_payload["msg"]["text"]
  
      event_payload["msg"].each do |index, val|
        logger.info index
      end
  
      ticket_email = event_payload["msg"]["email"]
      ticket_email_pieces = ticket_email.split(/@/)
      ticket_email_pieces = ticket_email_pieces[0].split(/-/)
      ticket_id = ticket_email_pieces[ticket_email_pieces.count - 1]
      logger.info "ticket id ------------->"
      logger.info ticket_id
      ticket = Ticket.find(ticket_id)
      user = User.find_by(:email => event_payload["msg"]["from_email"])
      if ticket and user
        response_message = event_payload["msg"]["text"]
        ticket_response_params = {:user_id => user.id, :response => response_message, :ticket_id => ticket.id}
        ticket_response = TicketResponse.new(ticket_response_params)
        if TicketResponsePolicy.new(user, ticket_response).create?
          if ticket_response.save
            logger.info "ticket response saved successfully"
            logger.info "ticket"
            logger.info ticket
            logger.info "ticket response message"
            logger.info response_message
            logger.info "ticket response id"
            logger.info ticket_response.id
            UserMailer.ticket_response_submitted_notification(ticket_response).deliver
          else
            logger.info ticket_response.errors
          end
        else
          logger.info "ticket response save failed"
          logger.info "user not authorized to reply on this ticket"
          logger.info "ticket"
          logger.info ticket
          logger.info "ticket response message"
          logger.info response_message
        end
      else
        logger.info "ticket not created. Either ticket or user does not exist"
      end
    end
  end
end
