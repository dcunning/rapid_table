# frozen_string_literal: true

require "rails/generators/base"

module RapidTable
  module Generators
    # Copy files to the application to get started with RapidTable
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Installs RapidTable into your Rails application"

      # TODO: allow the generate to specify a different name than "rapid_table" like "admin_table"
      # TODO: add `include UseRapidTables`` to the application controller

      def create_locale_file
        template "rapid_table.en.yml", "config/locales/rapid_table.en.yml"
      end

      def create_assets
        if false && tailwind?
          template "rapid_table.tailwind.scss", "app/assets/stylesheets/rapid_table.scss"
        else
          # NOTE: this file is just a compiled version of the tailwind CSS
          template "rapid_table.css", "app/assets/stylesheets/rapid_table.css"
        end

        template "rapid_table_controller.js", "app/javascript/controllers/rapid_table_controller.js"
      end

      def create_concern
        template "uses_rapid_tables.rb", "app/controllers/concerns/uses_rapid_tables.rb"
      end

      def create_view_component
        template "application_table.rb", "app/components/application_table.rb"
        template "application_table.html.erb", "app/components/application_table.html.erb"
      end
    end
  end
end
