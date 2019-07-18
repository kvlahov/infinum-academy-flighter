RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let(:companies) { FactoryBot.create_list(:company, 3) }

  describe 'GET /companies' do
    it 'returns list of companies' do
      get '/api/companies'

      expect(response).to have_http_status(:ok)
      expect(response.body.count).to eq(3)
    end
  end

  describe 'GET /companies/:id' do
    it 'returns single company' do
      get "/api/companies/#{companies.first.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['company']).to include('name')
    end
  end

  describe 'POST /companies' do
    context 'with valid parameters' do
      it 'creates company' do
        count = Company.all.count
        post '/api/companies',
             params: { company: { name: 'Emirates' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['company']).to include('name' => 'Emirates')
        expect(count).to eq(count + 1)
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        post '/api/companies',
             params: { company: { name: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'PUT /companies/:id' do
    context 'with valid parameters' do
      it 'creates company' do
        put "/api/companies#{companies.first.id}",
            params: { company: { name: 'Emirates' } }.to_json

        expect(response).to have_http_status(:no_content)
        expect do
          Company.find(companies.first.id).name
        end.to eq('Emirates')
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        put '/api/companies',
            params: { id: companies.first.id, company: { name: '' } }.to_json

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'DELETE /companies/:id' do
    it 'deletes company' do
      count = Company.all.count
      delete "/api/companies/#{companies.last.id}"

      expect(result).to have_http_status(:no_content)
      expect(count).to eq(count - 1)
    end
  end
end
