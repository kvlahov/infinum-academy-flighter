RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse
  let!(:users) { FactoryBot.create_list(:user, 3) }

  describe 'GET /users' do
    it 'returns list of users' do
      get '/api/users'

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].count).to eq(3)
    end
  end

  describe 'GET /users/:id' do
    it 'returns single user' do
      get "/api/users/#{users.first.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['user']).to include('first_name')
    end
  end

  describe 'POST /users' do
    context 'with valid parameters' do
      it 'creates user' do
        count = User.all.count
        post '/api/users',
             params: {
               user: { first_name: 'Stipe', last_name: 'Stipic', email: 'stipe@mail.hr' }
             }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'Stipe', 'email' => 'stipe@mail.hr')
        expect(User.all.count).to eq(count + 1)
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
      it 'creates user' do
        put "/api/users/#{users.first.id}",
            params: { user: { first_name: 'Stipe' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(User.find(users.first.id).first_name).to eq('Stipe')
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        put "/api/users/#{users.first.id}",
            params: { user: { first_name: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name')
      end
    end
  end

  describe 'DELETE /users/:id' do
    it 'deletes user' do
      count = User.all.count
      delete "/api/users/#{users.last.id}"

      expect(response).to have_http_status(:no_content)
      expect(User.all.count).to eq(count - 1)
    end
  end
end
