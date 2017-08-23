
require "rack"

module Nancy
  class Base
    def initialize
      @routes = {}
    end

    attr_reader :routes
    attr_reader :request

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
        result = instance_eval(&handler)
        if result.class == String
          [200, {}, [result]]
        else
          result
        end
      else
        [404, {}, ["Oops! No route for #{verb} #{requested_path}"]]
      end

      module Delegator
        def self.delegate(*methods, to:)
          Array(methods).each do |method_name|
            define_method(method_name) do |*args, &block|
              to.send(method_name, *args, &block)
            end

            private method_name
          end
        end

        delegate :get, :patch, :put, :post, :delete, :head, to: Application
      end
    end


    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end

    def params
      request.params
    end
  end
  Application = Base.new
end

# # nancy = Nancy::Base.new
nancy_application = Nancy::Application
#
# handler
puts 1
nancy_application.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

puts nancy_application.routes


# route1
puts 2
nancy_application.get "/" do
  [200, {}, ["Your params are #{params.inspect}"]]
end
puts nancy_application.routes

#route2
puts 3
nancy_application.post "/" do
  [200, {}, request.body]
end

puts nancy_application.routes

puts 4
nancy_application.get "/hello" do
  "Nancy says hello!"
end

 puts nancy_application.routes


# # This line is new! Handler using WEBrick
# Rack::Handler::WEBrick.run nancy, Port: 9292


puts 5
nancy_application.get "/hello" do
  "Nancy::Application says hello"
end

puts nancy_application.routes
puts "The end."


# Use `nancy_application,` not `nancy`
Rack::Handler::WEBrick.run nancy_application, Port: 9292
