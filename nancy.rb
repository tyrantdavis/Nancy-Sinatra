
require "rack"

module Nancy
  class Base
    def initialize
      @routes = {}
    end

    attr_reader :routes

    def get(path, &handler)
      route("GET", path, &handler)
    end

    def call(env)
      @request = Rack::Request.new(env)
      verb = @request.request_method
      requested_path = @request.path_info

      handler = @routes[verb][requested_path]

      handler.call
    end

    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end
  end
end

nancy = Nancy::Base.new

nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

puts nancy.routes
