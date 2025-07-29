# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::DSL::Columns do
  let_table_class do
    extend RapidTable::DSL::Columns
  end

  describe "column definitions" do
    it "defines columns with basic options" do
      table_class.column :id, label: "ID"
      table_class.column :name, label: "Full Name"
      
      expect(table_class.columns.map(&:id)).to eq([:id, :name])
      expect(table_class.columns.map(&:label)).to eq(["ID", "Full Name"])
    end

    it "finds columns by id" do
      table_class.column :email
      column = table_class.find_column(:email)
      expect(column.id).to eq(:email)
    end

    it "raises error when column not found" do
      expect { table_class.find_column!(:missing) }.to raise_error(RapidTable::ColumnNotFoundError)
    end
  end

  describe "column groups" do
    before do
      table_class.column :id
      table_class.column :name
      table_class.column :email
    end

    it "defines column groups" do
      table_class.column_group :basic, [:name, :email]
      group = table_class.find_column_group(:basic)
      expect(group.id).to eq(:basic)
      expect(group.column_ids).to eq([:name, :email])
    end

    it "finds column groups by id" do
      table_class.column_group :basic, [:name, :email]
      group = table_class.find_column_group!(:basic)
      expect(group.id).to eq(:basic)
    end

    it "raises error when column group not found" do
      expect { table_class.find_column_group!(:missing) }.to raise_error(RapidTable::ColumnGroupNotFoundError)
    end
  end

  describe "finding columns" do
    before do
      table_class.column :id
      table_class.column :name
      table_class.column_group :basic, [:id, :name]
    end

    it "finds columns by ids" do
      columns = table_class.find_columns!(column_ids: [:id, :name])
      expect(columns.map(&:id)).to eq([:id, :name])
    end

    it "finds columns by group id" do
      columns = table_class.find_columns!(column_group_id: :basic)
      expect(columns.map(&:id)).to eq([:id, :name])
    end

    it "raises error when both ids and group specified" do
      expect { table_class.find_columns!(column_ids: [:id], column_group_id: :basic) }
        .to raise_error(ArgumentError, "column_ids and column_group_id cannot be used together")
    end

    it "raises error when neither specified" do
      expect { table_class.find_columns! }
        .to raise_error(ArgumentError, "column_ids or column_group_id must be specified")
    end
  end

  describe "inheritance" do
    let(:parent_class) do
      Class.new do
        include RapidTable::Support
        extend RapidTable::DSL::Columns
        column :id
        column :name

        column_group :basic, [:name]
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        column :email
      end
    end

    it "inherits columns from parent" do
      expect(child_class.columns.map(&:id)).to eq([:id, :name, :email])
    end

    it "inherits column groups from parent" do
      expect(child_class.column_groups.map(&:id)).to eq([:basic])
    end

    it "finds parent columns" do
      column = child_class.find_column(:id)
      expect(column.id).to eq(:id)
    end
  end
end
