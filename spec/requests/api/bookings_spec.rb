RSpec.describe 'Booking API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /bookings' do
    before { FactoryBot.create_list(:booking, 3) }

    context 'when user is admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'returns list of all bookings' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(3)
      end
    end

    context 'when user is not admin' do
      let(:user) { FactoryBot.create(:user, first_name: 'User', token: 'abc123') }

      before { FactoryBot.create(:booking, user_id: user.id) }

      it 'returns own booking' do
        get '/api/bookings',
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(1)
        expect(json_body['bookings'].first['user']).to include('first_name' => 'User')
      end
    end

    context 'when unauthenticated request' do
      before { FactoryBot.create(:user) }

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

      let!(:bookings) { FactoryBot.create_list(:booking, 3) }

      it 'returns single booking' do
        get "/api/bookings/#{bookings.first.id}",
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats')
      end
    end

    context 'when user is not admin, get own booking' do
      let(:user) { FactoryBot.create(:user, token: 'abc123') }
      let(:booking) { FactoryBot.create(:booking, user_id: user.id) }

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
      before { FactoryBot.create(:user) }

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

      it 'creates booking' do # rubocop: disable ExampleLength
        expect do
          post '/api/bookings',
               params:
                {
                  booking:
                  {
                    no_of_seats: 80,
                    seat_price: 120,
                    flight_id: FactoryBot.create(:flight).id
                  }
                }.to_json,
               headers: auth_headers('abc123')
        end.to change { Booking.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include('no_of_seats' => 80, 'seat_price' => 120)
        expect(json_body['booking']['user']).to include('id' => user.id)
      end
    end

    context 'when user with invalid parameters' do
      before { FactoryBot.create(:user, token: 'abc123') }

      it 'returns 400 bad request' do
        post '/api/bookings',
             params: { booking: { no_of_seats: '' } }.to_json,
             headers: auth_headers('abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end

    context 'when user is not authenticated' do
      before { FactoryBot.create(:user) }

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

      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'updates booking' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: { no_of_seats: '80' } }.to_json,
              headers: auth_headers('abc123')
        end.to change { Booking.find(booking.id).no_of_seats }.to(80)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters as admin' do
      let(:booking) { FactoryBot.create(:booking) }

      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      it 'returns 400 bad request' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { no_of_seats: '' } }.to_json,
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end

    context 'when user updates own booking' do
      let(:user) { FactoryBot.create(:user, first_name: 'Batman', token: 'abc123') }
      let(:booking) { FactoryBot.create(:booking, no_of_seats: '20', user_id: user.id) }

      it 'succesfuly updates booking' do
        expect do
          put "/api/bookings/#{booking.id}",
              params: { booking: { no_of_seats: '80' } }.to_json,
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
      before { FactoryBot.create(:user) }

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
    context 'when admin deletes user' do
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
      before { FactoryBot.create(:user) }

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
