require 'singleton'
require 'pg'
class DBConnection
  attr_accessor :dbname
  include Singleton

  def exec(sql, args=[])
    connection.exec_params(sql, args)
  end

  def connection
    PG.connect(dbname: dbname, host: 'localhost')
  end
end
