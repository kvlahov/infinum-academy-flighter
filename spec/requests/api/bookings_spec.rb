RSpec.describe 'Booking API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /bookings' do
    before { FactoryBot.create_list(:booking, 3) }

    it 'returns list of bookings' do
      get '/api/bookings'

      expect(response).to have_http_status(:ok)
      expect(json_body['bookings'].count).to eq(3)
    end
  end

  describe 'GET /bookings/:id' do
    let(:booking) { FactoryBot.create(:booking) }

    it 'returns single booking' do
      get "/api/bookings/#{booking.id}"

      expect(response).to have_http_status(:ok)
      expect(json_body['booking']).to include('no_of_seats')
    end
  end

  describe 'POST /bookings' do
    context 'with valid parameters' do
      it 'creates booking' do # rubocop: disable ExampleLength
        expect do
          post '/api/bookings',
               params:
                {
                  booking:
                  {
                    no_of_seats: 80,
                    seat_price: 120,
                    user_id: FactoryBot.create(:user).id,
                    flight_id: FactoryBot.create(:flight).id
                  }
                }.to_json,
               headers: api_headers
        end.to change { Booking.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include('no_of_seats' => 80, 'seat_price' => 120)
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
    let(:booking) { FactoryBot.create(:booking) }

    context 'with valid parameters' do
      it 'updates booking' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: { no_of_seats: '80' } }.to_json,
              headers: api_headers
        end.to change { Booking.find(booking.id).no_of_seats }.to(80)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      it 'returns 400 bad request' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { no_of_seats: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  describe 'DELETE /bookings/:id' do
    let!(:booking) { FactoryBot.create(:booking) }

    it 'deletes booking' do
      expect do
        delete "/api/bookings/#{booking.id}"
      end.to change { Booking.all.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
