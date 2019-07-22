RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /users' do
    before { FactoryBot.create_list(:user, 3) }

    it 'returns list of users' do
      get '/api/users'

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].count).to eq(3)
    end
  end

  describe 'GET /users/:id' do
    let(:user) { FactoryBot.create(:user) }

    it 'returns single user' do
      get "/api/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['user']).to include('first_name')
    end
  end

  describe 'POST /users' do
    context 'with valid parameters' do
      it 'creates user' do
        expect do
          post '/api/users',
               params: {
                 user: { first_name: 'Stipe', last_name: 'Stipic', email: 'stipe@mail.hr' }
               }.to_json,
               headers: api_headers
        end.to change { User.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'Stipe', 'email' => 'stipe@mail.hr')
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        post '/api/users',
             params: { user: { first_name: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name')
      end
    end
  end

  describe 'PUT /users/:id' do
    context 'with valid parameters' do
      let(:user) { FactoryBot.create(:user, first_name: 'Shime') }

      it 'creates user' do
        expect do
          put "/api/users/#{user.id}",
              params: { user: { first_name: 'Stipe' } }.to_json,
              headers: api_headers
        end.to change { User.find(user.id).first_name }.to('Stipe')

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      let(:user) { FactoryBot.create(:user) }

      it 'returns 400 bad request' do
        put "/api/users/#{user.id}",
            params: { user: { first_name: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name')
      end
    end
  end

  describe 'DELETE /users/:id' do
    let!(:user) { FactoryBot.create(:user) }

    it 'deletes user' do
      expect do
        delete "/api/users/#{user.id}"
      end.to change { User.all.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
