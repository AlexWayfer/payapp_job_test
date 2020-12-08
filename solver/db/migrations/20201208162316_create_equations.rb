# frozen_string_literal: true

Sequel.migration do
	change do
		create_table :equations do
			primary_key :id

			column :a, Float, null: false
			column :b, Float, null: false
			column :c, Float, null: false

			column :x1, Float, null: true
			column :x2, Float, null: true
		end
	end
end
