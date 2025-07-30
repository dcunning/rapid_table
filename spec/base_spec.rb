# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::Base do
  describe "#table_path" do
    it "adds a table param to support multiple tables in the same action" do
      pending "need enable #url_for"
      table = RapidTable::Base.new([], param_name: :users)
      expect(table.table_path).to eq("/users.csv?table=users")
    end

    it "adds a table param even when there's only one table to ensure turbo knows its the table that needs to be updated"

    it "generates a path with the format at the top level with a param_name" do
      pending "need enable #url_for"
      table = RapidTable::Base.new([], param_name: :users)
      expect(table.table_path(format: :csv, page: 2)).to eq("/users.csv?table=users&users[page]=2")
    end
  end
end
