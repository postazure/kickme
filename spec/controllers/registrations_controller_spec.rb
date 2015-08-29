require 'rails_helper'

describe RegistrationsController do
  describe '#create' do
    let( :payload ) do
      {
          'user' => {
              'email' => 'fake@email.com',
              'password' => 'password'
          }
      }
    end

    let( :headers ) { {} }
    it 'should create a new user' do
      expect(User.count).to eq 0
      post :create, payload, headers

      expect(User.count).to eq 1
    end
  end
end