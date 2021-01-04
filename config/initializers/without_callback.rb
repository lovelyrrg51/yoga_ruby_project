module ActiveSupport::Callbacks::ClassMethods
  class WithoutCallbacks
    # include ActiveSupport::Callbacks
    def initialize(target, args)
      @_target = target
      @callbacks = args
      @_callbacks = []
      @_deactivated_callbacks = []
      default_callback_names = [:create, :save, :update, :destroy, :find, :initialize, :rollback, :touch, :validate, :validation, :commit]
      default_callback_names.each do |name|
        @_callbacks += target.send("_#{name.to_s}_callbacks").collect{|chain| {filter: chain.filter, kind: chain.kind, name: chain.name} }
      end
    end

    def deactivate_callbacks
      @callbacks.each do |method|
        callbacks = @_callbacks.select{|c| c.filter == method}
        # raise "Callback not found with name #{method.to_s}." unless callbacks.present?
        next unless callbacks.present?
        callbacks.each do |callback|
          @_target.skip_callback(callback.name, callback.kind, callback.filter)
          @_deactivated_callbacks.push(callback)
        end
      end
    end

    def activate_callbacks
      @_deactivated_callbacks.each do |callback|
        @_target.set_callback(callback.name, callback.kind, callback.filter)
      end
    end

  end

  # If method is called without block then activation of callbacks will be done manually
  def without_callbacks(*args)
    raise ArgumentError, 'Wrong number of argument 0 for 1 or more.' if args.empty?
    woc = WithoutCallbacks.new(self, args)
    woc.deactivate_callbacks
    if block_given?
      begin
        yield
      ensure
        woc.activate_callbacks
      end
    else
      woc
    end
  end
end
