# This concern enables namespaces in Pundit. In order to use it, put this
# module into the `app/controllers/concerns` folder of your project and then
# include the module into the controller you want to namespace the policies in
# after the include of Pundit.
#
# To secify the namespace to use, overwrite the `pundit_namespace` method on
# your controller then.
#
# Example
# =======
#
# ```ruby
# class API::V3::BaseController < ApplicationController
#   include Pundit
#   include Concerns::PunditNamespaces
#
#   def pundit_user
#     current_user
#   end
#
#   def pundit_namespace
#     V3
#   end
# end
# ```
#
# In order to re-implement as few things as possible, the policies and the
# scopes are resolved by Pundit::PolicyFinder which returns the resolved class
# without a namespace. Therefor a dummy policy without a namespace has to
# exist, otherwise you will get a class not found exception.
#
module Concerns::PunditNamespaces
  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end

  module InstanceMethods
    # To set the namespace, overwrite this method in your controller
    def pundit_namespace
      Object
    end

    def policies
      NamespacedPolicyFinder.new(pundit_user, pundit_namespace)
    end

    def policy_scopes
      NamespacedPolicyScopeFinder.new(pundit_user, pundit_namespace)
    end
  end

  class NamespacedPolicyFinder
    def initialize(user, namespace)
      @user = user
      @namespace = %w(Comfy::Cms Comfy::Blog V2).include?(namespace.to_s) ? nil : namespace
    end

    def policies
      @_policies ||= {}
    end

    def [](object)
      policies[object] ||= begin
        policy = Pundit::PolicyFinder.new(object).policy
        policy = "#{@namespace}::#{policy.to_s}".constantize
        policy.new(@user, object)
      end
    end
  end

  class NamespacedPolicyScopeFinder
    def initialize(user, namespace)
      @user = user
      @namespace = namespace
    end

    def policy_scopes
      @_policy_scopes ||= {}
    end

    def [](object)
      policy_scopes[object] ||= begin
        policy = Pundit::PolicyFinder.new(object).scope
        policy = "#{@namespace}::#{policy.to_s}".constantize
        policy.new(@user, object).resolve
      end
    end
  end
end
