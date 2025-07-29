# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::Search do
  let_table_class do
    include RapidTable::Search
  end

  let(:table) { table_class.new([]) }

  describe "config options" do
    it "initializes with default values" do
      table = table_class.new([])
      expect(table.search_param).to eq(:q)
      expect(table.skip_search?).to be_falsey
    end

    it "allows custom search configuration" do
      table = table_class.new([], search_param: :search, skip_search: true)
      expect(table.search_param).to eq(:search)
      expect(table.skip_search?).to be_truthy
    end
  end

  describe "search query" do
    it "gets search query from params" do
      table.params[:q] = "john"
      expect(table.search_query).to eq("john")
    end

    it "returns nil when no search query" do
      expect(table.search_query).to be_nil
    end
  end

  describe "search functionality" do
    it "requires extension for filtering" do
      expect { table.filter_search(nil) }.to raise_error(RapidTable::ExtensionRequiredError)
    end
  end
end
