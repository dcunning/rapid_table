# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::DSL::Export do
  let_table_class do
    extend RapidTable::DSL::Export
  end

  describe "class attributes" do
    it "has default values" do
      expect(table_class.skip_export).to be_falsey
      expect(table_class.csv_column_separator).to eq(",")
      expect(table_class.export_batch_size).to eq(1000)
    end

    it "allows setting class attributes" do
      table_class.skip_export = true
      table_class.csv_column_separator = ";"
      table_class.export_batch_size = 500
      
      expect(table_class.skip_export).to be_truthy
      expect(table_class.csv_column_separator).to eq(";")
      expect(table_class.export_batch_size).to eq(500)
    end
  end

  describe "configuration inheritance" do
    it "inherits class attributes to instance config" do
      table_class.skip_export = true
      table_class.csv_column_separator = ";"
      table_class.export_batch_size = 500
      
      table = table_class.new([], columns: [])
      expect(table.skip_export?).to be_truthy
      expect(table.csv_column_separator).to eq(";")
      expect(table.export_batch_size).to eq(500)
    end

    it "allows instance-level overrides" do
      table_class.skip_export = false
      table_class.csv_column_separator = ","
      table_class.export_batch_size = 1000
      
      table = table_class.new([], 
        columns: [],
        skip_export: true,
        csv_column_separator: ";",
        export_batch_size: 500
      )
      expect(table.skip_export?).to be_truthy
      expect(table.csv_column_separator).to eq(";")
      expect(table.export_batch_size).to eq(500)
    end
  end
end 