module RapidTable
  module Export
    extend ActiveSupport::Concern

    included do
      include RapidTable::Columns

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

    def initialize_export(config)
      config.csv_column_separator ||= ","
      config.export_batch_size ||= 1000
      config.export_formats ||= %i[csv json]
      config.skip_export = config.export_formats.empty? if config.skip_export.nil?
    end

    def export_columns
      columns.clone.reject(&:skip_export?)
    end

    def stream_csv(stream)
      with_export do
        row_sep = "\n"

        stream.write(CSV.generate_line(export_columns.map(&:label), row_sep:))

        each_record(batch_size: export_batch_size, skip_pagination: true) do |record|
          cells = export_columns.map do |column|
            column_cell(record, column)
          end

          stream.write(CSV.generate_line(cells, row_sep:))
        end
      end
    end

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

    def with_export
      @exporting_data = true
      yield
    ensure
      @exporting_data = false
    end

    def exporting_data?
      @exporting_data
    end

    def export_table_path(format, **options)
      options = options.reverse_merge(registered_params)
      if param_name
        url_for(action: action_name, param_name => options.merge(format:), format:)
      else
        url_for(action: action_name, format:, **options)
      end
    end

    def each_record(batch_size: nil, skip_pagination: false)
      raise ExtensionRequiredError
    end
  end
end
