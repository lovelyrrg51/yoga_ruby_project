# https://gist.github.com/mamantoha/9c0aec7958c7636cebef
# app/controllers/concerns/orderable.rb
module Orderable
  extend ActiveSupport::Concern

  module ClassMethods
  end

  # A list of the param names that can be used for ordering the model list
  def ordering_params(params)
    # For example it retrieves a list of experiences in descending order of price.
    # Within a specific price, older experiences are ordered first
    #
    # GET /api/v1/experiences?sort=-price,created_at
    # ordering_params(params) # => { price: :desc, created_at: :asc }
    # Experience.order(price: :desc, created_at: :asc)
    #
    ordering = []

    if params[:sort].present?
      sort_order = { '-' => 'DESC', '+' => 'ASC' }

      sorted_params = params[:sort].split(',')
      sorted_params.each do |attr|
        sort_sign = (attr =~ /\A[+-]/) ? attr.slice!(0) : '+'
        ordering << "#{attr} #{sort_order[sort_sign]}"
      end
    end
    ordering.size > 0 ? ordering.join(', ') : 'id'
  end
end
