# frozen_string_literal: true

require 'grape'

require_relative '../config/main'

## Required by models
Solver::DB.connection

module Solver
	module Routes
		## API controller
		class API < Grape::API
			format :json
			prefix :api

			resource :equation do
				require_relative '../models/equation'

				desc 'Create an equation.'

				params do
					requires :a, type: Float, desc: '`a` variable.', except_values: [0.0]
					requires :b, type: Float, desc: '`b` variable.'
					requires :c, type: Float, desc: '`c` variable.'
				end

				post do
					equation = Models::Equation.create(params.slice(:a, :b, :c))
					{ id: equation.id }
				end

				desc 'Solve an existing equation.'
				params do
					requires :id, type: Integer, desc: 'Equation ID.'
				end
				route_param :id do
					require_relative '../services/solve_and_check'

					patch :solve do
						id = params[:id]
						equation = Models::Equation[id]

						error!({ error: "equation with `id = #{id}` not found" }, 404) unless equation

						service = Services::SolveAndCheck.new(equation)

						result = service.call

						error!({ error: service.error }, 400) unless result

						result ## roots
					end
				end
			end
		end
	end
end
