RSpec.describe 'Booking API', type: :request do
  include TestHelpers::JsonResponse
  let!(:bookings) { FactoryBot.create_list(:booking, 3) }

  describe 'GET /bookings' do
    it 'returns list of bookings' do
      get '/api/bookings'

      expect(response).to have_http_status(:ok)
      expect(json_body['bookings'].count).to eq(3)
    end
  end

  describe 'GET /bookings/:id' do
    it 'returns single booking' do
      get "/api/bookings/#{bookings.first.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['booking']).to include('no_of_seats')
    end
  end

  describe 'POST /bookings' do
    context 'with valid parameters' do
      it 'creates booking' do # rubocop: disable ExampleLength
        count = Booking.all.count
        post '/api/bookings',
             params:
             {
               booking:
               {
                 no_of_seats: 80, seat_price: 120,
                 user_id: FactoryBot.create(:user).id,
                 flight_id: FactoryBot.create(:flight).id
               }
             }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include('no_of_seats' => '80', 'seat_price': 120)
        expect(Booking.all.count).to eq(count + 1)
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        post '/api/bookings',
             params: { booking: { no_of_seats: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  describe 'PUT /bookings/:id' do
    context 'with valid parameters' do
      it 'creates booking' do
        put "/api/bookings/#{bookings.first.id}",
            params: { booking: { no_of_seats: '80' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(Booking.find(bookings.first.id).no_of_seats).to eq(80)
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        put "/api/bookings/#{bookings.first.id}",
            params: { booking: { no_of_seats: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  describe 'DELETE /bookings/:id' do
    it 'deletes booking' do
      count = Booking.all.count
      delete "/api/bookings/#{bookings.last.id}"

      expect(response).to have_http_status(:no_content)
      expect(Booking.all.count).to eq(count - 1)
    end
  end
end
