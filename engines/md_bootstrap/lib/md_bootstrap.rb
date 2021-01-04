require "md_bootstrap/version"

module MDBootstrap
  class Error < StandardError; end

  module Rails
    class Engine < ::Rails::Engine
    end
  end
end
