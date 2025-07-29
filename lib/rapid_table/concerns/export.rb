# frozen_string_literal: true

module RapidTable
  # The Export module provides functionality for exporting table data in various formats
  # in RapidTable. It exposes the following configuration options to RapidTable::Base:
  #
  # @option config csv_column_separator [String] The separator to use for CSV exports (default: ",")
  # @option config export_batch_size [Integer] The number of records to process in each batch (default: 1000)
  # @option config export_formats [Array<Symbol>] The formats available for export (default: [:csv, :json])
  # @option config skip_export [Boolean] Whether to skip export functionality entirely
  #
  # Column-level export options:
  # @option config column.skip_export [Boolean] Whether to exclude this column from exports
  module Export
    extend ActiveSupport::Concern

    included do
      include Columns

      register_initializer :export

      config_class! do
        attr_accessor :csv_column_separator
        attr_accessor :export_batch_size
        attr_accessor :export_formats
        attr_accessor :skip_export

        alias_method :skip_export?, :skip_export
      end

      with_options to: :config do
        delegate :csv_column_separator
        delegate :export_batch_size
        delegate :export_formats
        delegate :skip_export?
      end

      column_class! do
        attr_accessor :skip_export
        alias_method :skip_export?, :skip_export
      end
    end

    # Returns columns that should be included in exports, filtering out those marked as skip_export.
    #
    # @return [Array<Column>] The columns to include in exports
    def export_columns
      columns.clone.reject(&:skip_export?)
    end

    # Streams CSV data to the provided stream object.
    #
    # @param stream [IO] The stream to write CSV data to
    # @return [void]
    def stream_csv(stream)
      require "csv"

      with_export do
        row_sep = "\n"

        stream.write(CSV.generate_line(export_columns.map(&:id), row_sep:))

        each_record(batch_size: export_batch_size, skip_pagination: true) do |record|
          cells = export_columns.map do |column|
            column_cell(record, column)
          end

          stream.write(CSV.generate_line(cells, row_sep:))
        end
      end
    end

    # Exports table data as JSON.
    #
    # @return [Array<Hash>] Array of hashes representing table records
    def to_json(*_args)
      with_export do
        data = []

        each_record(batch_size: export_batch_size, skip_pagination: true) do |record|
          data << export_columns.each_with_object({}) do |column, hash|
            hash[column.id] = column_cell(record, column)
          end
        end

        data
      end
    end

    # Checks if the table is currently exporting data. Useful for deciding
    # whether a cell should include HTML or plain text.
    #
    # @return [Boolean] True if currently exporting, false otherwise
    def exporting_data?
      @exporting_data
    end

    # rubocop:disable Lint/UnusedMethodArgument

    # Iterates over records for export processing. Must be implemented by extensions.
    #
    # @param batch_size [Integer, nil] The number of records to process in each batch
    # @param skip_pagination [Boolean] Whether to skip pagination during export
    # @yield [record] Block to execute for each record
    # @raise [ExtensionRequiredError] If no extension provides this functionality
    def each_record(batch_size: nil, skip_pagination: false)
      raise ExtensionRequiredError
    end
    # rubocop:enable Lint/UnusedMethodArgument

  private

    # Initializes export configuration with default values.
    #
    # @param config [Object] The configuration object containing export settings
    # @return [void]
    def initialize_export(config)
      config.csv_column_separator ||= ","
      config.export_batch_size ||= 1000
      config.export_formats ||= %i[csv json]
      config.skip_export = config.export_formats.empty? if config.skip_export.nil?
    end

    # Executes a block within the export context, setting the exporting_data flag.
    #
    # @yield The block to execute during export
    # @return [Object] The result of the yielded block
    def with_export
      @exporting_data = true
      yield
    ensure
      @exporting_data = false
    end
  end
end
