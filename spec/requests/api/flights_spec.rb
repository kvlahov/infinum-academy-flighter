RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /flights' do
    context 'with name_cont filter' do
      let(:str) { 'spli' }

      before do
        ['Split', 'zagreb-split', 'Urugvaj'].each { |name| FactoryBot.create(:flight, name: name) }
      end

      it 'returns flights containing value in name, case insensitive' do
        get '/api/flights',
            params: { name_cont: str }

        expect(json_body['flights'].count).to eq(2)
      end
    end

    context 'with flys_at_eq filter' do
      let(:target_flys_at) { 2.days.from_now }

      before do
        [2.days.from_now, 8.days.from_now].each { |time| FactoryBot.create(:flight, flys_at: time) }
      end

      it 'returns flights with flys_at equal to value' do
        get '/api/flights',
            params: { flys_at_eq: target_flys_at }

        expect(json_body['flights'].count).to eq(1)
      end
    end

    context 'with no_of_available_seats_gteq filter' do
      let(:value) { 50 }
      let(:invalid_flight) { FactoryBot.create(:flight, no_of_seats: 100) }

      before do
        FactoryBot.create(:flight, no_of_seats: 100)
        FactoryBot.create(:booking, no_of_seats: 80, flight: invalid_flight)
      end

      it 'returns flights with available seats greater than or equal to value' do
        get '/api/flights',
            params: { no_of_available_seats_gteq: value }

        expect(json_body['flights'].count).to eq(1)
      end
    end

    context 'without filters' do
      before { FactoryBot.create_list(:flight, 3) }

      it 'checks if status is ok' do
        get '/api/flights'

        expect(response).to have_http_status(:ok)
      end

      it 'returns list of flights' do
        get '/api/flights'

        expect(json_body['flights'].count).to eq(3)
      end
    end

    context 'when sorting by flys_at' do
      before { FactoryBot.create(:flight, flys_at: 1.day.from_now) }

      let!(:later_flight) { FactoryBot.create(:flight, flys_at: 2.days.from_now) }

      it 'checks sorting' do
        get '/api/flights',
            params: { sort: 'flys_at' }

        expect(json_body['flights'].last['id']).to eq(later_flight.id)
      end
    end

    context 'when sorting by name' do
      before { FactoryBot.create(:flight, name: 'a') }

      let!(:flight) { FactoryBot.create(:flight, name: 'z') }

      it 'checks sorting' do
        get '/api/flights',
            params: { sort: 'name' }

        expect(json_body['flights'].last['id']).to eq(flight.id)
      end
    end

    context 'when sorting by created_at' do
      before { FactoryBot.create_list(:flight, 2) }

      it 'checks sorting' do
        get '/api/flights',
            params: { sort: 'created_at' }

        expect(json_body['flights'].first['created_at'])
          .to be < json_body['flights'].last['created_at']
      end
    end

    describe 'Flight Serializer' do
      let(:flight) { FactoryBot.create(:flight) }

      before { FactoryBot.create(:booking, no_of_seats: 20, flight: flight) }

      it 'checks no_of_booked_seats' do
        get '/api/flights'

        expect(json_body['flights'].first['no_of_booked_seats']).to eq(20)
      end
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

      let(:company) { FactoryBot.create(:company) }
      let(:valid_parameters) do
        {
          name: 'Zagreb-Split',
          flys_at: 5.hours.from_now,
          lands_at: 6.hours.from_now,
          base_price: 120,
          no_of_seats: 50,
          company_id: company.id
        }
      end

      it 'creates flight' do
        expect do
          post '/api/flights',
               params:
               { flight: valid_parameters }.to_json,
               headers: auth_headers('abc123')
        end.to change { Flight.all.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include('name' => 'Zagreb-Split', 'base_price' => 120)
      end
    end

    context 'with invalid parameters as admin' do
      before { FactoryBot.create(:user, role: 'admin', token: 'abc123') }

      let(:invalid_parameters) { { name: '' } }

      it 'returns 400 bad request' do
        post '/api/flights',
             params: { flight: invalid_parameters }.to_json,
             headers: auth_headers('abc123')

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end

    context 'when user is not admin' do
      before { FactoryBot.create(:user, token: 'abc123') }

      it 'returns 403 forbidden' do
        post '/api/flights',
             params: { flight: { name: 'BritishAirlines' } }.to_json,
             headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user, token: '') }

      it 'returns 401 unauthorized' do
        post '/api/flights',
             params: { flight: { name: 'BritishAirlines' } }.to_json,
             headers: auth_headers('abc123')

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
              headers: auth_headers('abc123')
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
            headers: auth_headers('abc123')

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
            headers: auth_headers('abc123')

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end

    context 'when unauthorized request' do
      before { FactoryBot.create(:user, token: '') }

      let(:flight) { FactoryBot.create(:flight) }

      it 'returns 401 unauthorized' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: '' } }.to_json,
            headers: auth_headers('abc123')

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
      before { FactoryBot.create(:user, token: '') }

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
