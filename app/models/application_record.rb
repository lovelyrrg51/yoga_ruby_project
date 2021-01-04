require 'active_record/diff'
class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include CommonHelper
  include Filterable
  include ActiveRecord::Diff

end
