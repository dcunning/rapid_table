require "sandbox_helper"

RSpec.describe "Sorting", type: :system do
  let_table_class superclass: ApplicationTable do
    extend RapidTable::DSL::Sorting

    include RapidTable::Ext::Array

    column :id, sortable: true, sort_order: :desc
    column :name, sortable: true
  end

  let(:record_class) { Struct.new(:id, :name) }
  let(:records) { (1..50).map { |i| record_class.new(i, "Name #{i}.") } }
  
  it "clicking on a column to sort by it and clicking again to reverse the sort order" do
    table_class.sort_column = :name
    table_class.sort_order = :asc
    mock_table skip_pagination: true

    visit mocked_table_path
    expect(page).to have_sorted_table_header("Name", :asc)
    expect(page).to have_sortable_table_header("Id")
    expect("Name 1.").to appear_before("Name 2.")
    click_on "Name▲"
    expect(page).to have_sorted_table_header("Name", :desc)
    expect(page).to have_sortable_table_header("Id")
    expect("Name 2.").to appear_before("Name 1.")

    click_on "Id"
    expect(page).to have_sorted_table_header("Id", :desc)
    expect(page).to have_sortable_table_header("Name")
    expect("Name 2.").to appear_before("Name 1.")
    click_on "Id"
    expect(page).to have_sorted_table_header("Id", :asc)
    expect(page).to have_sortable_table_header("Name")
    expect("Name 1.").to appear_before("Name 2.")
  end

  private

  def have_sorted_table_header(label, order)
    text = order == :asc ? "#{label}▲" : "#{label} \n▼"
    have_css(".admin-table-header-cell-link", text:)
  end

  def have_sortable_table_header(label)
    have_css(".admin-table-header-cell-link", text: "#{label}▲\n▼")
  end
end
