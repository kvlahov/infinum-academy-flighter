RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /users' do
    before { FactoryBot.create_list(:user, 3) }

    context 'when user is admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'returns list of all users' do
        get '/api/users',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(4)
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, first_name: 'User', token: 'abc123') }

      it 'returns 403 forbidden' do
        get '/api/users',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthenticated request' do
      before { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        get '/api/users',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'GET /users/:id' do
    context 'when user is admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:user) { FactoryBot.create(:user) }

      it 'returns single user' do
        get "/api/users/#{user.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name')
      end
    end

    context 'when user is not admin, get self' do
      let(:user) { FactoryBot.create(:user, token: 'abc123') }

      it 'returns this user info' do
        get "/api/users/#{user.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name')
      end
    end

    context 'when user is not admin, get other' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let!(:other_user) { FactoryBot.create(:user) }

      it 'returns 403 forbidden' do
        get "/api/users/#{other_user.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when user is not authenticated' do
      let(:user) { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        get "/api/users/#{user.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'POST /users' do
    context 'with valid parameters' do
      let(:valid_parameters) do
        { first_name: 'Stipe', last_name: 'Stipic',
          email: 'stipe@mail.hr', password: 'abc123' }
      end

      it 'creates user' do
        expect do
          post '/api/users',
               params: { user: valid_parameters }.to_json,
               headers: api_headers
        end.to change { User.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'Stipe', 'email' => 'stipe@mail.hr')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_parameters) { { first_name: '' } }

      it 'returns 400 bad request' do
        post '/api/users',
             params: { user: invalid_parameters }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name')
      end
    end
  end

  describe 'PUT /users/:id' do
    context 'with valid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:user) { FactoryBot.create(:user, first_name: 'Shime') }
      let(:valid_parameters) { { first_name: 'Stipe' } }

      it 'updates user' do
        expect do
          put "/api/users/#{user.id}",
              params: { user: valid_parameters }.to_json,
              headers: auth_headers('abc123')
        end.to change { User.find(user.id).first_name }.to('Stipe')

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:user) { FactoryBot.create(:user) }
      let(:invalid_parameters) { { first_name: '' } }

      it 'returns 400 bad request' do
        put "/api/users/#{user.id}",
            params: { user: invalid_parameters }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name')
      end
    end

    context 'when user updates self' do
      let(:user) { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }
      let(:valid_parameters) { { first_name: 'Stipe' } }

      it 'updates user' do
        expect do
          put "/api/users/#{user.id}",
              params: { user: valid_parameters }.to_json,
              headers: auth_headers('abc123')
        end.to change { User.find(user.id).first_name }.to('Stipe')

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user updates other user' do
      before { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }

      let(:other) { FactoryBot.create(:user) }

      it 'returns 403 forbidden' do
        put "/api/users/#{other.id}",
            params: { user: { first_name: 'Stipe' } }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when user updates role' do
      let(:user) { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }

      it 'fails to update role' do
        expect do
          put "/api/users/#{user.id}",
              params: { user: { role: 'admin' } }.to_json,
              headers: auth_headers('abc123')
        end.not_to change(User.find(user.id), :role)
      end
    end

    context 'when admin updates role' do
      let(:user) { FactoryBot.create(:user) }

      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'succesfuly changes user role' do
        expect do
          put "/api/users/#{user.id}",
              params: { user: { role: 'admin' } }.to_json,
              headers: auth_headers('abc123')
        end.to change { User.find(user.id).role }.to('admin')

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when unauthenticated request' do
      let(:user) { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        put "/api/users/#{user.id}",
            params: { user: { first_name: '' } }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'DELETE /users/:id' do
    context 'when admin deletes user' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:user) { FactoryBot.create(:user) }

      it 'deletes user' do
        expect do
          delete "/api/users/#{user.id}",
                 headers: { 'Authorization': 'abc123' }
        end.to change { User.all.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user deletes other user' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let!(:user) { FactoryBot.create(:user) }

      it 'returns 403 forbidden' do
        expect do
          delete "/api/users/#{user.id}",
                 headers: { 'Authorization': 'abc123' }
        end.to change { User.all.count }.by(0)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthenticated request' do
      let!(:user) { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        delete "/api/users/#{user.id}"

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
