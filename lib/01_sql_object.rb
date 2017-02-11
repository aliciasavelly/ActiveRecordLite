require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        "#{self.table_name}"
      LIMIT
        0
    SQL

    @columns = cols.map { |el| el.to_sym }
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
        #{@table_name}
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
    search = DBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        "#{@table_name}"
      WHERE
        id = ?
    SQL
    return nil if search.empty?
    self.new(search.first)
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
    attribute_vals = []

    self.class.columns.each do |column|
      attribute_vals << send(column)
    end

    attribute_vals
  end

  def insert
    num_vals = attribute_values.length - 1
    columns = self.class.columns.drop(1)
    col_names = columns.map { |el| el.to_s }.join(", ")
    vals = (["?"] * num_vals).join(", ")

    DBConnection.instance.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{vals})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
