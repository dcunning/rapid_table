class MockedTablesController < ApplicationController
  cattr_accessor :table_class
  cattr_accessor :records
  cattr_accessor :options
  cattr_accessor :block

  def show
    @table = self.class.table_class.new(
      self.class.records,
      params:,
      template: view_context,
      **(self.class.options || {}),
      &self.class.block
    )
  end
end
