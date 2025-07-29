module TableClassSupport
  extend ActiveSupport::Concern

  def new_table_class(superclass: RapidTable::Base, class_name: "TestTable", **options, &block)
    klass = Class.new(superclass, **options)
    klass.class_eval(&block) if block
    stub_const(class_name, klass)
    klass
  end

  class_methods do
    def let_table_class(**options, &block)
      let(:table_class) { new_table_class(**options, &block) }
      let(:column_class) { table_class.column_class }
      let(:config_class) { table_class.config_class }
    end
  end
end

RSpec.configure do |config|
  config.include TableClassSupport
end
