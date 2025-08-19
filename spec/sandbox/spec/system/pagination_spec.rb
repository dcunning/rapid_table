require Rails.root.join("spec/rails_helper")

RSpec.describe "Pagination", type: :system do
  let_table_class superclass: ApplicationTable do
    extend RapidTable::DSL::Columns
    extend RapidTable::DSL::Pagination

    include RapidTable::Ext::Array

    column :id
    column :name
  end

  let(:record_class) { Struct.new(:id, :name) }
  let(:records) { (1..100).map { |i| record_class.new(i, "Name #{i}.") } }

  it "shows the next page" do
    mock_table
    visit mocked_table_path
    records[0..24].each do |record|
      expect(page).to have_content(record.name)
    end
    click_on "Next"
    records[25..49].each do |record|
      expect(page).to have_content(record.name)
    end
  end
end
