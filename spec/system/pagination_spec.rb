require "rails_helper"

RSpec.describe "Pagination", type: :system do
  let_table_class do
    extend RapidTable::DSL::Columns
    extend RapidTable::DSL::Pagination
    extend RapidTable::Ext::Array

    column :id
    column :name
  end

  let(:records) { (1..100).map { |i| { id: i, name: "Name #{i}" } } }

  it "shows the next page" do
    mock_table
    visit table_path
    puts page.body
    expect(page).to have_content("1")
  end

  # cattr_accessor :table_class
  # cattr_accessor :records
  # cattr_accessor :options
  # cattr_accessor :block

  private

  def mock_table(table_class: self.table_class, records: self.records, **options, &block)
    allow(TableController).to receive(:table_class).and_return(table_class)
    allow(TableController).to receive(:records).and_return(records)
    allow(TableController).to receive(:options).and_return(options)
    allow(TableController).to receive(:block).and_return(block)
  end
end
