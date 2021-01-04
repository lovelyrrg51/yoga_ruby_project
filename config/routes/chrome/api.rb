namespace :api do
  [:v1, :v2].map { |api| draw api, 'chrome/api' }
end