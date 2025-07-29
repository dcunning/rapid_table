# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::Columns do
  let_table_class do
    include RapidTable::Columns
  end

  let(:id_column) { column_class.new(id: :id) }
  let(:name_column) { column_class.new(id: :name) }
  let(:email_column) { column_class.new(id: :email) }
  let(:table) { table_class.new([], columns: [id_column, name_column]) }

  describe "config options" do
    it "initializes columns" do
      table = table_class.new([], columns: [id_column, name_column])
      expect(table.columns).to eq([id_column, name_column])
    end

    it "builds column classes when given an array of hashes" do
      table = table_class.new([], columns: [{id: :id}, {id: :name}])
      expect(table.columns.map(&:class)).to eq([column_class, column_class])
      expect(table.columns.map(&:id)).to eq([:id, :name])
    end

    it "raises error when no columns specified" do
      expect { table_class.new([]) }.to raise_error(ArgumentError, "columns must be specified")
    end

    it "filters out certain columns with the except option" do
      table = table_class.new([], columns: [id_column, name_column, email_column], except: :email)
      expect(table.columns).to eq([id_column, name_column])
    end

    it "keeps only certain columns with the only option" do
      table = table_class.new([], columns: [id_column, name_column, email_column], only: [:id, :email])
      expect(table.columns).to eq([id_column, email_column])
    end
  end

  describe "#column_label" do
    it "renders column label" do
      column = column_class.new(id: :name, label: "Full Name")
      result = table.column_label(column)
      expect(result).to include("Full Name")
    end

    it "uses titleized id when no label provided" do
      column = column_class.new(id: :user_name)
      result = table.column_label(column)
      expect(result).to include("User Name")
    end
  end

  describe "#column_cell" do
    let(:record) { double("record", id: 1, name: "John Doe") }

    it "renders cell content from record attribute" do
      column = column_class.new(id: :name)
      result = table.column_cell(record, column)
      expect(result).to eq("John Doe")
    end

    it "renders cell content based on its type" do
      column = column_class.new(id: :name)

      table.instance_eval do
        def string_cell(record)
          "STRING"
        end
      end

      result = table.column_cell(record, column)
      expect(result).to eq("STRING")
    end

    it "uses custom cell method before falling back to the type" do
      column = column_class.new(id: :email, cell_method: :formatted_email)
      table = table_class.new([], columns: [column])

      table.instance_eval do
        def formatted_email(record)
          "FORMATTED"
        end

        def string_cell(record)
          "STRING"
        end
      end

      result = table.column_cell(record, column)
      expect(result).to eq("FORMATTED")
    end
  end
end
