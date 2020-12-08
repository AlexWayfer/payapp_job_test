# frozen_string_literal: true

require 'grape'

require_relative '../config/main'

module Checker
	module Routes
		## API controller
		class API < Grape::API
			format :json
			prefix :api

			desc 'Check roots.'

			params do
				requires :x1, type: Float, desc: 'The first root.'
				requires :x2, type: Float, desc: 'The second root.'
			end

			post :check do
				status 200

				raise 'Random error' if Checker.environment != 'test' && rand > 0.75

				{ valid: params[:x1].positive? && params[:x2].positive? }
			end
		end
	end
end
