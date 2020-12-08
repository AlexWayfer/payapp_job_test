# frozen_string_literal: true

require 'memery'
require 'yaml'

module Solver
	class << self
		include Memery

		memoize def environment
			ENV['RACK_ENV'] ||= 'development'
		end
	end
end

require_relative 'database'
require_relative 'checker'
