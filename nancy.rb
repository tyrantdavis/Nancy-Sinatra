
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
    
    def post(path, &handler)
      route("POST", path, &handler)
    end

    def put(path, &handler)
      route("PUT", path, &handler)
    end

    def patch(path, &handler)
      route("PATCH", path, &handler)
    end

    def delete(path, &handler)
      route("DELETE", path, &handler)
    end

    def call(env)
      @request = Rack::Request.new(env)
      verb = @request.request_method
      requested_path = @request.path_info

      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      if handler
        instance_eval(&handler)
      else
        [404, {}, ["Oops! No route for #{verb} #{requested_path}"]]
      end
    end


    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end

    def params
      @request.params
    end
  end
end

nancy = Nancy::Base.new
# handler
nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

puts nancy.routes


# handler
nancy.get "/" do
  [200, {}, ["Your params are #{params.inspect}"]]
end
puts nancy.routes

# This line is new!
Rack::Handler::WEBrick.run nancy, Port: 9292
