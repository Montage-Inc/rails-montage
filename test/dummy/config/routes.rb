require 'montage_rails/mock_server'

Rails.application.routes.draw do
  mount MontageRails::MockServer => "/montage_rails_mock"
end
