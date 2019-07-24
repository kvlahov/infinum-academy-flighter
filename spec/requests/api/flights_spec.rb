RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /flights' do
    before { FactoryBot.create_list(:flight, 3) }

    it 'returns list of flights' do
      get '/api/flights'

      expect(response).to have_http_status(:ok)
      expect(json_body['flights'].count).to eq(3)
    end
  end

  describe 'GET /flights/:id' do
    let(:flight) { FactoryBot.create(:flight) }

    it 'returns single flight' do
      get "/api/flights/#{flight.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['flight']).to include('name')
    end
  end

  describe 'POST /flights' do
    context 'with valid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'creates flight' do # rubocop: disable ExampleLength
        expect do
          post '/api/flights',
               params:
               {
                 flight:
                 {
                   name: 'Zagreb-Split', flys_at: 5.hours.from_now,
                   lands_at: 6.hours.from_now, base_price: 120,
                   no_of_seats: 50, company_id: FactoryBot.create(:company).id
                 }
               }.to_json,
               headers: api_headers.merge('Authorization': 'abc123')
        end.to change { Flight.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include('name' => 'Zagreb-Split', 'base_price' => 120)
      end
    end

    context 'with invalid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'returns 400 bad request' do
        post '/api/flights',
             params: { flight: { name: '' } }.to_json,
             headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      it 'returns 403 forbidden' do
        post '/api/flights',
             params: { flight: { name: 'BritishAirlines' } }.to_json,
             headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user) }

      it 'returns 401 unauthorized' do
        post '/api/flights',
             params: { flight: { name: 'BritishAirlines' } }.to_json,
             headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'PUT /flights/:id' do
    context 'with valid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:flight) { FactoryBot.create(:flight, name: 'London-Amsterdam') }

      it 'updates flight' do
        expect do
          put "/api/flights/#{flight.id}",
              params: { flight: { name: 'Zagreb-Split' } }.to_json,
              headers: api_headers.merge('Authorization': 'abc123')
        end.to change { Flight.find(flight.id).name }.to('Zagreb-Split')

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:flight) { FactoryBot.create(:flight) }

      it 'returns 400 bad request' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: '' } }.to_json,
            headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let(:flight) { FactoryBot.create(:flight) }

      it 'returns 403 forbidden' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: '' } }.to_json,
            headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user) }

      let(:flight) { FactoryBot.create(:flight) }

      it 'returns 401 unauthorized' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: '' } }.to_json,
            headers: api_headers.merge('Authorization': 'abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'DELETE /flights/:id' do
    context 'when user is admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:flight) { FactoryBot.create(:flight) }

      it 'deletes flight' do
        expect do
          delete "/api/flights/#{flight.id}",
                 headers: { 'Authorization': 'abc123' }
        end.to change { Flight.all.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let!(:flight) { FactoryBot.create(:flight) }

      it 'returns 403 forbidden' do
        delete "/api/flights/#{flight.id}",
               headers: { 'Authorization': 'abc123' }

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user) }

      let!(:flight) { FactoryBot.create(:flight) }

      it 'returns 401 unauthorized' do
        delete "/api/flights/#{flight.id}",
               headers: { 'Authorization': 'abc123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
