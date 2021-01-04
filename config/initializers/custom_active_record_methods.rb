module ActiveRecord
  module QueryMethods
    def syorder(*args)
      args.first.select!{|k, v| spawn.attribute_names.include?(k) }
      check_if_method_has_arguments!(:order, args)
      spawn.order!(*args)
    end
  end
end
