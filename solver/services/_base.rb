# frozen_string_literal: true

module Solver
	module Services
		## Base service class with common helpers
		class Base
			include Memery

			attr_reader :error

			def initialize
				@error = nil
			end
		end
	end
end
