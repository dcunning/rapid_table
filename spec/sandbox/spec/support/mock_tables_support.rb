module MockTablesSupport
  def mock_table(table_class: self.table_class, records: self.records, **options, &block)
    allow(MockedTablesController).to receive(:table_class).and_return(table_class)
    allow(MockedTablesController).to receive(:records).and_return(records)
    allow(MockedTablesController).to receive(:options).and_return(options)
    allow(MockedTablesController).to receive(:block).and_return(block)
  end
end

RSpec.configure do |config|
  config.include MockTablesSupport, type: :system
end
