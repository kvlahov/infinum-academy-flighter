RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let!(:flights) { FactoryBot.create_list(:flight, 3) }

  describe 'GET /flights' do
    it 'returns list of flights' do
      get '/api/flights'

      expect(response).to have_http_status(:ok)
      expect(json_body['flights'].count).to eq(3)
    end
  end

  describe 'GET /flights/:id' do
    it 'returns single flight' do
      get "/api/flights/#{flights.first.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['flight']).to include('name')
    end
  end

  describe 'POST /flights' do
    context 'with valid parameters' do
      it 'creates flight' do # rubocop: disable ExampleLength
        count = Flight.all.count
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
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include('name' => 'Zagreb-Split', 'base_price' => 120)
        expect(Flight.all.count).to eq(count + 1)
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        post '/api/flights',
             params: { flight: { name: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'PUT /flights/:id' do
    context 'with valid parameters' do
      it 'creates flight' do
        put "/api/flights/#{flights.first.id}",
            params: { flight: { name: 'Zagreb-Split' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(Flight.find(flights.first.id).name).to eq('Zagreb-Split')
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        put "/api/flights/#{flights.first.id}",
            params: { flight: { name: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'DELETE /flights/:id' do
    it 'deletes flight' do
      count = Flight.all.count
      delete "/api/flights/#{flights.last.id}"

      expect(response).to have_http_status(:no_content)
      expect(Flight.all.count).to eq(count - 1)
    end
  end
end
