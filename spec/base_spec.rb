# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::Base do
  describe "#table_path" do
    it "generates a path with the format at the top level even when the param_name is present" do
      pending "need enable #url_for"
      table = RapidTable::Base.new([], param_name: :users)
      expect(table.table_path(format: :csv, page: 2)).to eq("/users.csv?users[page]=2")
    end
  end
end
