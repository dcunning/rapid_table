module RapidTable
  module BulkActions
    def self.included(base)
      base.class_eval do
        include RapidTable::Support

        register_initializer :bulk_actions

        attr_accessor :bulk_actions

        config_class! do
          attr_accessor :skip_bulk_actions
          attr_accessor :bulk_actions
          attr_accessor :bulk_actions_param

          alias_method :skip_bulk_actions?, :skip_bulk_actions
        end

        with_options to: :config do
          delegate :skip_bulk_actions?
          delegate :bulk_actions_param
        end

        def_extendable_class :bulk_action do
          attr_accessor :id
          attr_accessor :label
        end
      end
    end

    def bulk_action_label(bulk_action)
      bulk_action.label || RapidTable.t("bulk_actions.#{bulk_action.id}", table_name:) || bulk_action.id.to_s.titleize
    end

    def selected_bulk_action_record_ids
      # TODO: only retain these when just performed a bulk action
      @selected_bulk_action_record_ids ||= full_params[bulk_actions_param] || []
    end

    def selected_bulk_action_record?(record)
      selected_bulk_action_record_ids.include?(record_id(record).to_s)
    end

    def bulk_actions_select_all_check_box_tag(**options)
      @template.check_box_tag(
        "select_all",
        nil,
        false,
        **options,
        data: hotwire_data(
          options,
          action: stimulus_actions(
            "change", "toggleBulkActionsSelections",
            "change", "toggleBulkActionPerform",
          ),
        ),
      )
    end

    def bulk_actions_select_one_check_box_tag(record, **options)
      id = record_id(record)

      @template.check_box_tag(
        "#{bulk_actions_param}[]",
        id,
        selected_bulk_action_record?(record),
        id: "select_#{record.class.name.underscore}_#{id}",
        title: "Select #{record.class.name.underscore.humanize}", # TODO: i18n
        **options,
        data: hotwire_data(
          options,
          stimulus_target => "bulkActionsRowSelect",
          action: stimulus_action("change", "toggleBulkActionPerform"),
        ),
      )
    end

    def bulk_actions_select_tag(**options)
      placeholder_choice = [t("bulk_actions.placeholder"), nil]
      choices = bulk_actions.map { |bulk_action| [bulk_action_label(bulk_action), bulk_action.id] }

      @template.select_tag(
        nil, # JavaScript cleverness will submit the bulk action
        options_for_select([placeholder_choice] + choices),
        id: id_for(:bulk_actions),
        **options,
        data: hotwire_data(
          options,
          action: stimulus_action("change", "toggleBulkActionPerform"),
          stimulus_target => "bulkActionSelect",
        ),
      )
    end

    def bulk_actions_submit_tag(path: table_path(action: :bulk_action), method: "POST", **options)
      @template.submit_tag(
        t("bulk_actions.button"),
        title: t("bulk_actions.button_title"),
        **options,
        data: hotwire_data(
          options,
          action: stimulus_action("click", "submitBulkAction"),
          stimulus_target => "bulkActionPerform",
          param: bulk_actions_param,
          path:,
          method:,
        ),
      )
    end

  private

    def initialize_bulk_actions(config)
      self.bulk_actions = self.class.build_bulk_actions(config.bulk_actions || [])

      config.bulk_actions_param ||= :ids
      config.skip_bulk_actions = true if bulk_actions.empty?
    end
  end
end
