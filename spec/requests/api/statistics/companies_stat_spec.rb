RSpec.describe 'Companies Statistics', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /api/statistics/companies' do
    context 'when user is authorized' do
      let(:company) { FactoryBot.create(:company) }
      let(:flight) do
        FactoryBot.create(
          :flight,
          no_of_seats: 100,
          base_price: 100,
          company: company
        )
      end

      before do
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
        FactoryBot.create(:booking, no_of_seats: 10, flight: flight, seat_price: 200)
      end

      it 'checks status is ok' do
        get '/api/statistics/companies',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
      end

      it 'checks total revenue' do
        # seat_price: 200
        get '/api/statistics/companies',
            headers: auth_headers('abc123')

        expect(json_body['companies'].first['total_revenue']).to eq(2000)
      end

      it 'checks total_no_of_booked_seats' do
        get '/api/statistics/companies',
            headers: auth_headers('abc123')

        expect(json_body['companies'].first['total_no_of_booked_seats']).to eq(10)
      end

      it 'checks average_price_of_seats' do
        get '/api/statistics/companies',
            headers: auth_headers('abc123')

        expect(json_body['companies'].first['average_price_of_seats']).to eq(100)
      end
    end

    context 'when user is unauthorized, but authenticated' do
      before { FactoryBot.create(:user, role: '', token: 'abc123') }

      it 'returns 403 forbidden' do
        get '/api/statistics/companies',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when user is unauthenticated' do
      before { FactoryBot.create(:user, role: nil, token: '') }

      it 'returns 401 unauthorized' do
        get '/api/statistics/companies',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
