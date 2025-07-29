# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::DSL::Sorting do
  let_table_class do
    extend RapidTable::DSL::Sorting
  end

  describe "class attributes" do
    it "has default values" do
      expect(table_class.skip_sorting).to be_falsey
    end

    it "allows setting class attributes" do
      table_class.skip_sorting = true
      expect(table_class.skip_sorting).to be_truthy
    end
  end

  describe "sort configuration" do
    before do
      table_class.column :id
      table_class.column :name
      table_class.column :email
    end

    it "sets default sort column" do
      table_class.sort_column = :name
      expect(table_class.sort_column).to eq(:name)
    end

    it "sets default sort order" do
      table_class.sort_order = "desc"
      expect(table_class.sort_order).to eq("desc")
    end

    it "configures both sort column and order" do
      table_class.sort_column = :email
      table_class.sort_order = "asc"
      
      expect(table_class.sort_column).to eq(:email)
      expect(table_class.sort_order).to eq("asc")
    end
  end

  describe "configuration inheritance" do
    before do
      table_class.column :id
      table_class.column :name
    end

    it "inherits class attributes to instance config" do
      table_class.skip_sorting = true
      table_class.sort_column = :name
      table_class.sort_order = "desc"
      
      table = table_class.new([])
      expect(table.skip_sorting?).to be_truthy
      expect(table.config.sort_column_id).to eq(:name)
      expect(table.config.sort_order).to eq("desc")
    end

    it "allows instance-level overrides" do
      table_class.skip_sorting = false
      table_class.sort_column = :id
      table_class.sort_order = "asc"
      
      table = table_class.new([], 
        skip_sorting: true,
        column_group_id: :default
      )
      expect(table.skip_sorting?).to be_truthy
    end
  end

  describe "column group integration" do
    it "uses default column group for sort configuration" do
      table_class.column :id
      table_class.column :name
      
      table_class.sort_column = :name
      table_class.sort_order = "desc"
      
      group = table_class.find_column_group(:default)
      expect(group.sort_column_id).to eq(:name)
      expect(group.sort_order).to eq("desc")
    end
  end
end 