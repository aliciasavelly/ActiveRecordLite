require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    attributes = []
    cols = []

    params.each do |k, v|
      cols << k.to_s
      attributes << v
    end

    where_line = cols.map { |name| "#{self.table_name}.#{name} = ?"}.join(" AND ")

    result = DBConnection.instance.execute(<<-SQL, *attributes)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    
    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
