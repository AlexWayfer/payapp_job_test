# frozen_string_literal: true

require 'sequel'

module Solver
	module Database
		class << self
			include Memery

			memoize def configuration
				YAML.load_file("#{__dir__}/database.yaml")[Solver.environment]
			end

			memoize def connection
				Sequel.connect configuration
			end
		end
	end

	DB = Database
end
