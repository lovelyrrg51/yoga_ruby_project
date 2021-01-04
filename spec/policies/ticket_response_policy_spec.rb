RSpec.describe TicketResponsePolicy, type: :policy do
  subject { described_class }

  permissions :create? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false
      ticket = Ticket.new
      ticket_response = TicketResponse.new ticket: ticket
      expect(subject).to permit(user, ticket_response)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true
      ticket = Ticket.new
      ticket_response = TicketResponse.new ticket: ticket
      expect(subject).to permit(user, ticket_response)
    end

    it 'grants access if user created the ticket' do
      user = User.new super_admin: false, digital_store_admin: false
      ticket = Ticket.new user: user
      ticket_response = TicketResponse.new user: user, ticket: ticket
      expect(subject).to permit(user, ticket_response)
    end

    it 'denies access if user is not super/digital_store admin or user did not create the ticket' do
      user = User.new super_admin: false, digital_store_admin: false
      ticket = Ticket.new user: User.new
      ticket_response = TicketResponse.new ticket: ticket
      expect(subject).not_to permit(user, ticket_response)
    end
  end

  permissions :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false
      ticket = Ticket.new
      ticket_response = TicketResponse.new ticket: ticket
      expect(subject).to permit(user, ticket_response)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true
      ticket = Ticket.new
      ticket_response = TicketResponse.new ticket: ticket
      expect(subject).to permit(user, ticket_response)
    end

    it 'denies access if user is not super/digital_store admin' do
      user = User.new super_admin: false, digital_store_admin: false
      ticket = Ticket.new
      ticket_response = TicketResponse.new ticket: ticket
      expect(subject).not_to permit(user, ticket_response)
    end
  end
end
