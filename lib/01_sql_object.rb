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
        attributes[column] = value
      end

      define_method(column.to_sym) do
        attributes[column]
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
    arr_hash = DBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL

    self.parse_all(arr_hash)
  end

  def self.parse_all(results)
    objs = []

    results.each do |result|
      objs << self.new(result)
    end

    objs
  end

  def self.find(id)
    
  end

  def initialize(params = {})
    params.each do |key, val|
      unless self.class.columns.include?(key.to_sym)
        raise "unknown attribute '#{key}'"
      else
        self.send("#{key}=", val)
      end
    end
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
