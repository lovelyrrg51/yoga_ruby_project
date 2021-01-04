module Api::V1
  class PaymentRefundSerializer < ActiveModel::Serializer
    attributes :id, :requester_user, :responder_user, :action, :status, :event_id, :event_order_id, :event_order, :max_refundable_amount, :event_cancellation_plan_id, :amount_refunded, :request_object, :cancellation_charges
    
    def requester_user
    	return nil unless object.try(:requester_user).present?
    	return {id: object.requester_user.id, first_name: object.requester_user.name}
    end
  
    def responder_user
    	return nil unless object.try(:responder_user).present?
    	return {id: object.responder_user.id, first_name: object.responder_user.name}
    end
  
    def event_order
    	return nil unless object.try(:event_order).present?
    	return {id: object.event_order_id, transaction_id: object.event_order.transaction_id, status: object.event_order.status, reg_ref_number: object.event_order.reg_ref_number}
    end
  
    def request_object
      # return object.refunded? ? nil : object.request_object.except("errors", "refunds", "total_refunded_amount", "db_refundable_amount", "payment_refund_id", "action", "shifted_event_order_id", "details", "is_downgraded", "partial_refund")
      return object.request_object.except("errors", "refunds", "total_refunded_amount", "db_refundable_amount", "payment_refund_id", "action", "shifted_event_order_id", "details", "is_downgraded", "partial_refund")
    end
  
  end
end
