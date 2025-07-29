# frozen_string_literal: true

require "zeitwerk"
require "active_support/concern"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "dsl" => "DSL",
  "csv" => "CSV",
)
loader.collapse("#{__dir__}/rapid_table/concerns")
loader.setup

module RapidTable
  class Error < StandardError; end
  class ColumnNotFoundError < Error; end
  class ColumnGroupNotFoundError < Error; end
  class BulkActionNotFoundError < Error; end
  class RowActionNotFoundError < Error; end
  class ExtensionRequiredError < Error; end
  class ExtendableClassNotFoundError < Error; end

  class << self
    def t(key, table_name:)
      I18n.t(
        "rapid_table.#{table_name}.#{key}",
        default: I18n.t("rapid_table.default.#{key}", default: nil),
      )
    end

    # Load ViewComponent-dependent classes when Rails is available
    def load_view_components
      return unless defined?(Rails)

      require_relative "rapid_table/base"
      require_relative "rapid_table/components/pagination_links"
    end
  end
end

RapidTable::LOADER = loader
