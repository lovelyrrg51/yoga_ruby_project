class EventOrder < ApplicationRecord
  serialize :parameters, JSON
end
