# frozen_string_literal: true

require "rails_helper"

RSpec.describe RapidTable::DSL::Pagination do
  let_table_class do
    extend RapidTable::DSL::Pagination
  end

  describe "class attributes" do
    it "has default values" do
      expect(table_class.skip_pagination).to be_falsey
      expect(table_class.page_param).to eq(:page)
      expect(table_class.per_page_param).to eq(:per_page)
    end

    it "allows setting class attributes" do
      table_class.skip_pagination = true
      table_class.page_param = :p
      table_class.per_page_param = :size
      table_class.per_page = 25
      table_class.available_per_pages = [10, 25, 50]
      
      expect(table_class.skip_pagination).to be_truthy
      expect(table_class.page_param).to eq(:p)
      expect(table_class.per_page_param).to eq(:size)
      expect(table_class.per_page).to eq(25)
      expect(table_class.available_per_pages).to eq([10, 25, 50])
    end
  end

  describe "configuration inheritance" do
    it "inherits class attributes to instance config" do
      table_class.skip_pagination = true
      table_class.page_param = :p
      table_class.per_page_param = :size
      table_class.per_page = 25
      table_class.available_per_pages = [10, 25, 50]
      
      table = table_class.new([])
      expect(table.skip_pagination?).to be_truthy
      expect(table.page_param).to eq(:p)
      expect(table.per_page_param).to eq(:size)
      expect(table.per_page).to eq(25)
      expect(table.available_per_pages).to eq([10, 25, 50])
    end

    it "allows instance-level overrides" do
      table_class.skip_pagination = false
      table_class.page_param = :page
      table_class.per_page_param = :per
      table_class.per_page = 50
      table_class.available_per_pages = [25, 50, 100]
      
      table = table_class.new([], 
        skip_pagination: true,
        page_param: :p,
        per_page_param: :size,
        per_page: 25,
        available_per_pages: [10, 25, 50]
      )
      expect(table.skip_pagination?).to be_truthy
      expect(table.page_param).to eq(:p)
      expect(table.per_page_param).to eq(:size)
      expect(table.per_page).to eq(25)
      expect(table.available_per_pages).to eq([10, 25, 50])
    end
  end
end 