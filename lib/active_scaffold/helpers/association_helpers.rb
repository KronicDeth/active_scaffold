module ActiveScaffold
  module Helpers
    module AssociationHelpers
      # Provides a way to honor the :conditions on an association while searching the association's klass
      def association_options_find(association, conditions = nil, joins = nil)
        merged_conditions = controller.send(
          :merge_conditions,
          conditions,
          association.options[:conditions]
        )
        association.klass.find(
          :all,
          :conditions => merged_conditions,
          :joins => joins,
          :select => "DISTINCT #{association.klass.table_name}.*"
        )
      end

      def association_options_count(association, conditions = nil, joins = nil)
        merged_conditions = controller.send(
          :merge_conditions,
          conditions,
          association.options[:conditions]
        )
        association.klass.count(
          :all,
          :conditions => merged_conditions,
          :joins => joins
        )
      end

      # returns options for the given association as a collection of [id, label] pairs intended for the +options_for_select+ helper.
      def options_for_association(association, include_all = false)
        available_records = association_options_find(
          association,
          include_all ? nil : options_for_association_conditions(association),
          options_for_association_joins(association)
        )
        available_records ||= []
        available_records.sort{|a,b| a.to_label <=> b.to_label}.collect { |model| [ model.to_label, model.id ] }
      end

      def options_for_association_count(association)
        association_options_count(
          association,
          options_for_association_conditions(association),
          options_for_association_joins(association)
        )
      end

      # A useful override for customizing the records present in an association dropdown.
      # Should work in both the subform and form_ui=>:select modes.
      # Check association.name to specialize the conditions per-column.
      def options_for_association_conditions(association)
        return nil if association.options[:through]
        case association.macro
          when :has_one, :has_many
            # Find only orphaned objects
            "#{association.primary_key_name} IS NULL"
          when :belongs_to, :has_and_belongs_to_many
            # Find all
            nil
        end
      end
      
      def options_for_association_joins(association)
        nil
      end
    end
  end
end
