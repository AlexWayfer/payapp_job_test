# frozen_string_literal: true

require 'memery'

module Checker
	class << self
		include Memery

		memoize def environment
			ENV['RACK_ENV'] ||= 'development'
		end
	end
end
