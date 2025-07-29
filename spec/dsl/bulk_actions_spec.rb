# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::DSL::BulkActions do
  let_table_class do
    extend RapidTable::DSL::BulkActions
  end

  let(:table) { table_class.new([]) }

  describe "class attributes" do
    it "has default values" do
      expect(table_class.skip_bulk_actions).to be_falsey
      expect(table_class.bulk_actions_param).to eq(:ids)
    end

    it "allows setting class attributes" do
      table_class.skip_bulk_actions = true
      table_class.bulk_actions_param = :selected
      
      expect(table_class.skip_bulk_actions).to be_truthy
      expect(table_class.bulk_actions_param).to eq(:selected)
    end
  end

  describe "bulk action definitions" do
    it "defines bulk actions" do
      table_class.bulk_action :delete, label: "Delete Selected"
      table_class.bulk_action :archive, label: "Archive Selected"
      
      expect(table_class.bulk_actions.map(&:id)).to eq([:delete, :archive])
      expect(table_class.bulk_actions.map(&:label)).to eq(["Delete Selected", "Archive Selected"])

      expect(table.bulk_actions.map(&:id)).to eq([:delete, :archive])
      expect(table.bulk_actions.map(&:label)).to eq(["Delete Selected", "Archive Selected"])
    end

    it "finds bulk actions by id" do
      table_class.bulk_action :delete, label: "Delete"
      action = table_class.find_bulk_action(:delete)
      expect(action.id).to eq(:delete)
      expect(action.label).to eq("Delete")
    end

    it "raises error when bulk action not found" do
      expect { table_class.find_bulk_action(:missing) }.to raise_error(RapidTable::BulkActionNotFoundError)
    end
  end

  describe "inheritance" do
    let(:parent_class) do
      Class.new do
        include RapidTable::Support
        extend RapidTable::DSL::BulkActions
        bulk_action :delete
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        bulk_action :archive
      end
    end

    it "inherits bulk actions from parent" do
      expect(child_class.bulk_actions.map(&:id)).to eq([:delete, :archive])
    end

    it "finds parent bulk actions" do
      action = child_class.find_bulk_action(:delete)
      expect(action.id).to eq(:delete)
    end
  end
end 