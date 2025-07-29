# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::Sorting do
  let_table_class do
    include RapidTable::Sorting
  end

  let(:sortable_column) { column_class.new(id: :name, sortable: true, sort_order: "asc") }
  let(:table) { table_class.new([], columns: [sortable_column]) }

  describe "config options" do
    it "initializes with default values" do
      table = table_class.new([], columns: [])
      expect(table.sort_column_param).to eq(:sort)
      expect(table.sort_order_param).to eq(:dir)
      expect(table.skip_sorting?).to be_falsey
    end

    it "allows custom sorting configuration" do
      table = table_class.new([], 
        columns: [],
        sort_column_param: :order_by,
        sort_order_param: :direction,
        skip_sorting: true
      )
      expect(table.sort_column_param).to eq(:order_by)
      expect(table.sort_order_param).to eq(:direction)
      expect(table.skip_sorting?).to be_truthy
    end
  end

  describe "sort parameters" do
    it "gets sort column from params" do
      table.params[:sort] = "name"
      expect(table.sort_column_param_value).to eq("name")
    end

    it "gets sort order from params" do
      table.params[:dir] = "desc"
      expect(table.sort_order_param_value).to eq("desc")
    end

    it "validates sort order values" do
      table.params[:dir] = "invalid"
      expect(table.sort_order_param_value).to be_nil
    end
  end

  describe "sort order utilities" do
    it "reverses sort order" do
      expect(table.reverse_sort_order("asc")).to eq("desc")
      expect(table.reverse_sort_order("desc")).to eq("asc")
    end

    it "provides available sort orders" do
      expect(table.available_sort_orders).to eq(["asc", "desc"])
    end
  end

  describe "column sorting" do
    it "allows columns to be sortable" do
      column = column_class.new(id: :email, sortable: true, sort_order: "desc")
      expect(column.sortable?).to be_truthy
      expect(column.sort_order).to eq("desc")
    end

    it "requires extension for filtering" do
      expect { table.filter_sorting(nil) }.to raise_error(RapidTable::ExtensionRequiredError)
    end
  end
end
