# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module Solver
	module Checker
		class << self
			include Memery

			memoize def configuration
				YAML.load_file("#{__dir__}/checker.yaml")[Solver.environment]
			end

			memoize def connection
				Faraday.new configuration[:url] do |conn|
					conn.request :json
					conn.response :json, content_type: /\bjson$/
				end
			end
		end
	end
end
