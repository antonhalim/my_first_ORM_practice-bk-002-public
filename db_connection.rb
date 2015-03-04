require 'singleton'
require 'pg'
class DBConnection
  include Singleton

  def exec(sql, args=[])
    connection.exec_params(sql, args)
  end

  def connection
    @connection ||= PG.connect(dbname: 'hacktive_record_practice', host: 'localhost')
  end
end
