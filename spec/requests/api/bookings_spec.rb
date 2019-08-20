RSpec.describe 'Booking API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /bookings' do
    context 'when user is admin' do
      before do
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
        FactoryBot.create_list(:booking, 3)
      end

      it 'returns list of all bookings' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(json_body['bookings'].count).to eq(3)
      end

      it 'returns status ok' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when sorting by flight.flys_at' do
      let(:earlier_flight) { FactoryBot.create(:flight, flys_at: 2.days.from_now) }
      let(:later_flight) { FactoryBot.create(:flight, flys_at: 3.days.from_now) }

      before do
        FactoryBot.create(:booking, flight: earlier_flight)
        FactoryBot.create(:booking, flight: later_flight)
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
      end

      it 'sorts by flys_at' do
        get '/api/bookings',
            params: { sort: 'flights.flys_at' },
            headers: auth_headers('abc123')

        expect(json_body['bookings'].last['flight']['id']).to eq(later_flight.id)
      end
    end

    context 'when sorting by flight.name' do
      let(:earlier_flight) { FactoryBot.create(:flight, name: 'a') }
      let(:later_flight) { FactoryBot.create(:flight, name: 'b') }

      before do
        FactoryBot.create(:booking, flight: earlier_flight)
        FactoryBot.create(:booking, flight: later_flight)
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
      end

      it 'sorts by name' do
        get '/api/bookings',
            params: { sort: 'flights.name' },
            headers: auth_headers('abc123')

        expect(json_body['bookings'].last['flight']['name']).to eq(later_flight.name)
      end
    end

    context 'when sorting by created_at' do
      before do
        FactoryBot.create_list(:booking, 2)
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
      end

      it 'sorts by created_at' do
        get '/api/bookings',
            params: { sort: 'created_at' },
            headers: auth_headers('abc123')

        expect(json_body['bookings'].first['created_at'])
          .to be < json_body['bookings'].last['created_at']
      end
    end

    describe 'Booking Serializer total_price' do
      before do
        FactoryBot.create(:booking, seat_price: 100, no_of_seats: 10)
        FactoryBot.create(:user, role: 'admin', token: 'abc123')
      end

      it 'checks total_price calculation' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(json_body['bookings'].first['total_price']).to eq(1000)
      end
    end

    context 'when user is not admin' do
      let(:user) { FactoryBot.create(:user, first_name: 'User', token: 'abc123') }

      before { FactoryBot.create(:booking, user: user) }

      it 'returns own booking' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(1)
        expect(json_body['bookings'].first['user']).to include('first_name' => 'User')
      end
    end

    context 'when unauthenticated request' do
      before { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'GET /bookings/:id' do
    context 'when user is admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:booking) { FactoryBot.create(:booking) }

      it 'returns single booking' do
        get "/api/bookings/#{booking.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats')
      end
    end

    context 'when user is not admin, get own booking' do
      let(:user) { FactoryBot.create(:user, token: 'abc123') }
      let(:booking) { FactoryBot.create(:booking, user: user) }

      it 'returns this user info' do
        get "/api/bookings/#{booking.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats')
      end
    end

    context 'when user is not admin, get others booking' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let!(:booking) { FactoryBot.create(:booking) }

      it 'returns 403 forbidden' do
        get "/api/bookings/#{booking.id}",
            headers: auth_headers('abc123')

        expect(json_body['errors']).to include('resource')
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user is not authenticated' do
      before { FactoryBot.create(:user, token: '') }

      let(:booking) { FactoryBot.create(:booking) }

      it 'returns 401 unauthorized' do
        get "/api/bookings/#{booking.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'POST /bookings' do
    context 'when user with valid parameters' do
      let!(:user) { FactoryBot.create(:user, token: 'abc123') }
      let(:flight) { FactoryBot.create(:flight, flys_at: Time.current + 2.minutes, base_price: 50) }
      let(:valid_parameters) do
        { no_of_seats: 80, flight_id: flight.id }
      end

      it 'creates booking' do
        expect do
          post '/api/bookings',
               params: { booking: valid_parameters }.to_json,
               headers: auth_headers('abc123')
        end.to change { user.bookings.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include('no_of_seats' => 80)
        expect(json_body['booking']['user']).to include('id' => user.id)
      end

      it 'checks seat_price is double base_price' do
        post '/api/bookings',
             params: { booking: valid_parameters }.to_json,
             headers: auth_headers('abc123')

        expect(json_body['booking']).to include('seat_price' => 100)
      end
    end

    context 'when admin with valid parameters' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:other_user) { FactoryBot.create(:user) }
      let(:flight) { FactoryBot.create(:flight) }
      let(:valid_parameters) do
        { no_of_seats: 80,
          flight_id: flight.id,
          user_id: other_user.id }
      end

      it 'creates booking for other user' do
        expect do
          post '/api/bookings',
               params: { booking: valid_parameters }.to_json,
               headers: auth_headers('abc123')
        end.to(change { other_user.bookings.count }.by(1))
      end
    end

    context 'when user with invalid parameters' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let(:invalid_parameters) { { no_of_seats: '' } }

      it 'returns 400 bad request' do
        post '/api/bookings',
             params: { booking: invalid_parameters }.to_json,
             headers: auth_headers('abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end

    context 'when user is not authenticated' do
      before { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        post '/api/bookings',
             params: { booking: { no_of_seats: '' } }.to_json,
             headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'PUT /bookings/:id' do
    context 'with valid parameters as admin' do
      let(:booking) { FactoryBot.create(:booking, no_of_seats: '20') }
      let(:valid_parameters) { { no_of_seats: '80' } }

      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'updates booking' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: valid_parameters }.to_json,
              headers: auth_headers('abc123')
        end.to change { Booking.find(booking.id).no_of_seats }.to(80)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters as admin' do
      let(:booking) { FactoryBot.create(:booking) }
      let(:invalid_parameters) { { no_of_seats: '' } }

      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'returns 400 bad request' do
        put "/api/bookings/#{booking.id}",
            params: { booking: invalid_parameters }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end

    context 'when user updates own booking' do
      let(:user) { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }
      let(:booking) { FactoryBot.create(:booking, no_of_seats: '20', user: user) }
      let(:valid_parameters) { { no_of_seats: '80' } }

      it 'succesfuly updates booking' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: valid_parameters }.to_json,
              headers: auth_headers('abc123')
        end.to change { Booking.find(booking.id).no_of_seats }.to(80)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user updates others booking' do
      before { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }

      let(:booking) { FactoryBot.create(:booking) }

      it 'returns 403 forbidden' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { no_of_seats: '80' } }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when user tries to update user_id' do
      let(:user) { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }
      let(:booking) { FactoryBot.create(:booking) }

      it 'fails to update user_id' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: { user_id: user.id } }.to_json,
              headers: auth_headers('abc123')
        end.not_to(change { Booking.find(booking.id).user_id })
      end
    end

    context 'when admin updates user_id' do
      let(:booking) { FactoryBot.create(:booking) }
      let(:user) { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'succesfuly changes user_id' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: { user_id: user.id } }.to_json,
              headers: auth_headers('abc123')
        end.to(change { Booking.find(booking.id).user_id })

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when unauthenticated request' do
      before { FactoryBot.create(:user, token: '') }

      let(:booking) { FactoryBot.create(:booking) }

      it 'returns 401 unauthorized' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { no_of_seats: '80' } }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end

  describe 'DELETE /bookings/:id' do
    context 'when admin deletes booking' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let!(:booking) { FactoryBot.create(:booking) }

      it 'deletes booking' do
        expect do
          delete "/api/bookings/#{booking.id}",
                 headers: { 'Authorization': 'abc123' }
        end.to change { Booking.all.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user deletes others booking' do
      before { FactoryBot.create(:user, token: 'abc123') }

      let!(:booking) { FactoryBot.create(:booking) }

      it 'returns 403 forbidden' do
        expect do
          delete "/api/bookings/#{booking.id}",
                 headers: { 'Authorization': 'abc123' }
        end.to change { Booking.all.count }.by(0)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthenticated request' do
      before { FactoryBot.create(:user, token: '') }

      let!(:booking) { FactoryBot.create(:booking) }

      it 'returns 401 unauthorized' do
        delete "/api/bookings/#{booking.id}",
               headers: { 'Authorization': 'abc123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
