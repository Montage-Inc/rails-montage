require 'montage_rails/mock'

Rails.application.routes.draw do
  mount MontageRails::Mock => "/montage_rails_mock"
end
