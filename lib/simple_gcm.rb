require "bundler/setup"
require 'net/http'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

module SimpleGCM
  URL = "https://android.googleapis.com/gcm/send"

  def self.notify devices, options={}
    devices = Array(devices)
    request_data = {registration_ids: devices}
    request_data.merge! filter_options(options,
      :collapse_key,
      :data,
      :delay_while_idle,
      :time_to_live,
      :dry_run
    )

    uri = URI.parse(URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = request_data.to_json
    request.initialize_http_header(
        'Authorization' => "key=#{options[:key]}",
        'Content-Type' => 'application/json'
    )

    res = http.request(request)

    data = {}
    begin
      data = JSON.parse(res.body)
    rescue JSON::ParserError
    end

    Response.new(res, data, devices)
  end

  def self.filter_options options, *keys
    keys = keys.collect &:to_sym
    options.select do |key, value|
      keys.any? {|k| k == key.to_sym}
    end
  end

  class Response
    attr_accessor :http_response
    attr_accessor :data
    attr_accessor :registration_ids
  
    def initialize(res, data, devices)
      self.http_response = res
      self.data = HashWithIndifferentAccess.new_from_hash_copying_default(data)
      self.registration_ids = devices

      @results = {}
      self.registration_ids.each_with_index do |item, index|
        @results[item] = self.data[:results] && self.data[:results][index]
      end
    end

    def errors?
      self.http_response.code != '200' || self.data[:failures] != 0
    end

    def results
      @results
    end

    def each_error
      @results.each_key do |reg_id|
        result = @results[reg_id]
        error = result[:error]
        yield reg_id, error if error
      end
    end

    def each_registration_id
      @results.each_key do |old_id|
        result = @results[key]
        new_id = result[:registration_id]
        yield old_id, new_id if new_id
      end
    end

    def status
      self.http_response.code
    end
  end
end