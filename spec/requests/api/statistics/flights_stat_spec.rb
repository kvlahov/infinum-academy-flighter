RSpec.describe 'Flights Statistics', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /api/statistics/flights' do
    context 'when user is authorized' do
      let(:flight) do
        FactoryBot.create(:flight, no_of_seats: 100, base_price: 100)
      end

      before do
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
        FactoryBot.create(:booking, no_of_seats: 10, flight: flight, seat_price: 200)
      end

      it 'checks status is ok' do
        get '/api/statistics/flights',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
      end

      it 'checks revenue' do
        get '/api/statistics/flights',
            headers: auth_headers('abc123')

        expect(json_body['flights'].first['revenue']).to eq(2000)
      end

      it 'checks no_of_booked_seats' do
        get '/api/statistics/flights',
            headers: auth_headers('abc123')

        expect(json_body['flights'].first['no_of_booked_seats']).to eq(10)
      end

      it 'checks occupancy' do
        get '/api/statistics/flights',
            headers: auth_headers('abc123')

        expect(json_body['flights'].first['occupancy']).to eq('10.00%')
      end
    end

    context 'when user is unauthorized, but authenticated' do
      before do
        FactoryBot.create(:user, token: 'abc123')
        FactoryBot.create(:flight)
      end

      it 'returns 403 forbidden' do
        get '/api/statistics/flights',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when user is unauthenticated' do
      before { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        get '/api/statistics/flights',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
