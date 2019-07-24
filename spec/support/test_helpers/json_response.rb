module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end

    def api_headers
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    end

    def auth_headers(auth_token)
      api_headers.merge('Authorization': auth_token)
    end
  end
end
