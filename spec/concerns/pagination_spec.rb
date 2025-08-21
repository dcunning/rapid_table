# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::Pagination do
  let_table_class do
    include RapidTable::Pagination
  end

  let(:table) { table_class.new([]) }

  describe "config options" do
    it "initializes with default values" do
      table = table_class.new([])
      expect(table.page_param).to eq(:page)
      expect(table.per_page_param).to eq(:per)
      expect(table.available_per_pages).to eq([25, 50, 100])
      expect(table.skip_pagination?).to be_falsey
    end

    it "allows custom pagination configuration" do
      table = table_class.new([], 
        page_param: :p,
        per_page_param: :size,
        available_per_pages: [10, 20],
        skip_pagination: true
      )
      expect(table.page_param).to eq(:p)
      expect(table.per_page_param).to eq(:size)
      expect(table.available_per_pages).to eq([10, 20])
      expect(table.skip_pagination?).to be_truthy
    end
  end

  describe "pagination state" do
    it "hides pagination when only one page" do
      table = table_class.new([])
      allow(table).to receive(:total_records_count).and_return(20)
      expect(table.only_ever_one_page?).to be_truthy
    end

    it "requires extension for pagination methods" do
      expect { table.total_records_count }.to raise_error(RapidTable::ExtensionRequiredError)
      expect { table.total_pages }.to raise_error(RapidTable::ExtensionRequiredError)
      expect { table.current_page }.to raise_error(RapidTable::ExtensionRequiredError)
    end
  end

  describe "parameter handling" do
    it "gets per_page from params" do
      table.params[:per] = "50"
      expect(table.per_page_param_value).to eq(50)
    end

    it "gets page from params" do
      table.params[:page] = "2"
      expect(table.page_param_value).to eq("2")
    end
  end

  describe "not implemented methods" do
    %w[total_records_count total_pages current_page].each do |method|
      it "raises an error when #{method} is called" do
        expect { table.send(method) }.to raise_error(RapidTable::ExtensionRequiredError)
      end
    end
  end
end
