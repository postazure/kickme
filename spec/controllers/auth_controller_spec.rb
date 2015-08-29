require 'rails_helper'

describe AuthController do
  describe '#create' do
    let!( :existing_user ) { FactoryGirl.create(:user, email: 'fake@email.com', password: 'password') }
    context 'valid login credentials are provided' do
      let( :payload ) do
        {
            'email' => 'fake@email.com', 'password' => 'password'
        }
      end
      
      it 'should login and create a token' do
        response = post :create, payload
        response_body = JSON.parse(response.body)

        token = (existing_user.reload).token
        expect(response_body).to eq( { 'auth' => true, 'token' => token })
        expect(response.status).to eq 200
      end
    end

    context 'invalid login credentials are provided' do
      let( :payload ) do
        {
            'email' => 'fake@email.com', 'password' => 'wrong password'
        }
      end
      
      it 'should login and create a token' do
        response = post :create, payload
        response_body = JSON.parse(response.body)

        expect(response.status).to eq 401
        expect(response_body).to eq( 'auth' => false )
      end
    end
  end

  describe '#destroy' do
    let( :logged_in_user ) { FactoryGirl.create(:user) }

    context 'valid token' do
      let( :session_token ) { logged_in_user.token }

      it 'should ' do
        response = delete :destroy, { token: session_token }
        response_body = JSON.parse(response.body)

        expect(logged_in_user.reload.token).to be_nil
        expect(response.status).to eq 200
        expect(response_body).to eq( 'auth' => true )
      end
    end

    context 'invalid token' do
      it 'invalid token ' do
        response = delete :destroy, { token: 'foo' }
        response_body = JSON.parse(response.body)

        expect(logged_in_user.reload.token).not_to be_nil
        expect(response.status).to eq 422
        expect(response_body).to eq( 'auth' => false )
      end
    end
  end
end