class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.sorted(order_attribute = default_ordering)
    order_attribute = default_ordering if order_attribute.nil?

    if order_attribute.in? column_names
      order(order_attribute)
    else
      return all unless order_attribute.include?('.')

      order_by_association(order_attribute)
    end
  end

  def self.order_by_association(order_attribute)
    association_name = order_attribute.split('.').first
    association = reflect_on_all_associations(:belongs_to)
                  .select { |ass| ass.plural_name == association_name }
                  .map(&:name)
    return all if association.empty?

    joins(association.first).order(order_attribute)
  end

  def self.default_ordering
    'id'
  end
  private_class_method :order_by_association
end
