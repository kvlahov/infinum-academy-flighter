RSpec.describe 'Session API', type: :request do
  include TestHelpers::JsonResponse

  describe 'POST /session' do
    context 'with valid email and password' do
      let!(:user) { FactoryBot.create(:user, email: 'myusr@mail.com', password: 'usr123') }

      it 'logs in user' do
        post '/api/session',
             params: { session: { email: user.email, password: 'usr123' } }.to_json,
             headers: api_headers

        expect(json_body['session']).to include('token')
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid credentials' do
      let!(:user) { FactoryBot.create(:user, email: 'myusr@mail.com', password: 'usr123') }

      it 'returns 400 bad request' do
        post '/api/session',
             params: { session: { email: user.email, password: 'wrongpwd' } }.to_json,
             headers: api_headers

        expect(json_body['errors']).to include('credentials')
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'DELETE /session' do
    let!(:user) { FactoryBot.create(:user, password: 'usr123', token: 'abc-123') }

    it 'deletes session' do
      expect do
        delete '/api/session',
               headers: { 'Authorization': user.token }
      end.to change { User.find(user.id).token }.from(user.token)

      expect(response).to have_http_status(:no_content)
    end
  end
end
