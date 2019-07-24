RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /companies' do
    before { FactoryBot.create_list(:company, 3) }

    it 'returns list of companies' do
      get '/api/companies'

      expect(response).to have_http_status(:ok)
      expect(json_body['companies'].count).to eq(3)
    end
  end

  describe 'GET /companies/:id' do
    let(:company) { FactoryBot.create(:company) }

    it 'returns single company' do
      get "/api/companies/#{company.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['company']).to include('name')
    end
  end

  describe 'POST /companies' do
    context 'with valid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'creates company' do
        expect do
          post '/api/companies',
               params: { company: { name: 'Emirates' } }.to_json,
               headers: api_headers.merge('Authorization': 'abc123')
        end.to change { Company.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['company']).to include('name' => 'Emirates')
      end
    end

    context 'with invalid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'returns 400 bad request' do
        post '/api/companies',
             params: { company: { name: '' } }.to_json,
             headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      it 'returns 403 forbidden' do
        post '/api/companies',
             params: { company: { name: 'NewName' } }.to_json,
             headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user) }

      it 'returns 401 unauthorized' do
        post '/api/companies',
             params: { company: { name: 'NewName' } }.to_json,
             headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'PUT /companies/:id' do
    context 'with valid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:company) { FactoryBot.create(:company, name: 'CroatiaAirlines') }

      it 'updates company' do
        expect do
          put "/api/companies/#{company.id}",
              params: { company: { name: 'Emirates' } }.to_json,
              headers: api_headers.merge('Authorization': 'abc123')
        end.to change { Company.find(company.id).name }.to('Emirates')

        expect(response).to have_http_status(:ok)
        expect(Company.find(company.id).name).to eq('Emirates')
      end
    end

    context 'with invalid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:company) { FactoryBot.create(:company) }

      it 'returns 400 bad request' do
        put "/api/companies/#{company.id}",
            params: { company: { name: '' } }.to_json,
            headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let(:company) { FactoryBot.create(:company, name: 'CroatiaAirlines') }

      it 'returns 403 forbidden' do
        put "/api/companies/#{company.id}",
            params: { company: { name: '' } }.to_json,
            headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user) }

      let(:company) { FactoryBot.create(:company, name: 'CroatiaAirlines') }

      it 'returns 401 unauthorized' do
        put "/api/companies/#{company.id}",
            params: { company: { name: '' } }.to_json,
            headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'DELETE /companies/:id' do
    context 'when user is admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:company) { FactoryBot.create(:company) }

      it 'deletes company' do
        expect do
          delete "/api/companies/#{company.id}",
                 headers: { 'Authorization': 'abc123' }
        end.to change { Company.all.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let!(:company) { FactoryBot.create(:company) }

      it 'returns 403 forbidden' do
        delete "/api/companies/#{company.id}",
               headers: { 'Authorization': 'abc123' }

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user) }

      let!(:company) { FactoryBot.create(:company) }

      it 'returns 401 unauthorized' do
        delete "/api/companies/#{company.id}",
               headers: { 'Authorization': 'abc123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
