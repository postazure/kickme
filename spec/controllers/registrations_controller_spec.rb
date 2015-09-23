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

    it 'should create a new user' do
      expect(User.count).to eq 0
      response = post :create, payload
      response_body = JSON.parse(response.body)

      expect(User.count).to eq 1
      expect(response.status).to eq 200
      expect(response_body).to include( { 'registered' => true } )
    end

    it 'should return the new user\'s token' do
      response = post :create, payload
      response_body = JSON.parse(response.body)

      user = User.find_by_email('fake@email.com')
      token = user.token
      expect(response.status).to eq 200
      expect(response_body).to include( { 'token' => token })
    end

    describe 'Errors' do
      let!( :existing_user ) { FactoryGirl.create(:user, email: 'fake@email.com') }

      it 'should inform a new user if they cant make a new account' do
        response = post :create, payload
        response_body = JSON.parse(response.body)

        expect(response.status).to eq 422
        expect(response_body).to eq 'errors' => {'email' => ['has already been taken']}
      end
    end
  end
end