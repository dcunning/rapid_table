# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::DSL::Search do
  let_table_class do
    extend RapidTable::DSL::Search
  end

  describe "class attributes" do
    it "has default values" do
      expect(table_class.skip_search).to be_falsey
      expect(table_class.search_param).to eq(:q)
    end

    it "allows setting class attributes" do
      table_class.skip_search = true
      table_class.search_param = :search
      
      expect(table_class.skip_search).to be_truthy
      expect(table_class.search_param).to eq(:search)
    end
  end

  describe "configuration inheritance" do
    it "inherits class attributes to instance config" do
      table_class.skip_search = true
      table_class.search_param = :search
      
      table = table_class.new([])
      expect(table.skip_search?).to be_truthy
      expect(table.search_param).to eq(:search)
    end

    it "allows instance-level overrides" do
      table_class.skip_search = false
      table_class.search_param = :q
      
      table = table_class.new([], 
        skip_search: true,
        search_param: :search
      )
      expect(table.skip_search?).to be_truthy
      expect(table.search_param).to eq(:search)
    end
  end
end 