require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    DBConnection.execute2( "select * from #{self.table_name}" )[0].map do |el|
      el.to_sym
    end
  end

  def self.finalize!
    self.columns.each do |column|
      define_method("#{column}=") do |value|
        p value
        # self.instance_variable_set("@#{column}", value)
        attributes[column.to_sym] = value
        p @attributes
      end

      define_method(column) do
        self.instance_variable_get(@attributes["@#{column}"])
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
