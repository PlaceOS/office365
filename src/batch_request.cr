module Office365::BatchRequest
  def batch(requests : Indexable(HTTP::Request)) : Hash(HTTP::Request, HTTP::Client::Response)
    raise ArgumentError.new("maximum of 750 requests per batch request") if requests.size > 750

    responses = {} of HTTP::Request => HTTP::Client::Response

    # Maximum of 50 requests per-batch
    requests.each_slice(50, reuse: true) do |requests_slice|
      payload_request_arr = [] of RequestParam

      requests_slice.each_with_index do |request, id|
        body = request.body ? JSON.parse(request.body.not_nil!) : nil
        payload_request_arr << RequestParam.new(id: id, method: request.method, url: request.resource, body: body)
      end

      req_body = {"requests": payload_request_arr}

      endpoint = "/v1.0/$batch"

      http_req = graph_http_request(request_method: "POST", path: endpoint, data: req_body.to_json)
      batch_response = graph_request(http_req)

      parsed_response = JSON.parse(batch_response.body).as_h

      parsed_response["responses"].as_a.each do |res|
        res = res.as_h
        id = res["id"].to_s.to_i
        responses[requests_slice[id]] = parsed_to_http(res)
      end
    end

    responses
  end

  # Takes individual json response and changes it to http response
  private def parsed_to_http(res)
    body = res["body"]?.try(&.as_h).try(&.to_json)
    status = HTTP::Status.new(res["status"].as_i)
    headers = HTTP::Headers.new
    res_headers = res["headers"]?.try(&.as_h)
    if res_headers
      res_headers.each do |k, v|
        headers[k] = v.as_s
      end
    end
    HTTP::Client::Response.new(status: status, body: body, headers: headers)
  end

  struct RequestParam
    include JSON::Serializable

    property id : Int32
    property method : String
    property url : String
    property body : JSON::Any?

    def initialize(@id, @method, url, @body = nil)
      # Dont need to pass api version in the url
      @url = url.gsub("/v1.0", "")
    end
  end
end
