class Song
  attr_accessor :id, :title, :album_id

  def self.exec(sql, args=[])
    DBConnection.instance.exec(sql, args)
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    results = exec(sql)
    results.map do |row|
      new(row)
    end
  end

  def self.find(id)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE id=$1
      LIMIT 1
    SQL

    results = exec(sql, [id])

    results.map do |row|
      new row
    end.first
  end

  def initialize(options={})
    options.each do |property, value|
      public_send("#{property}=", value)
    end
  end

  def save
    if self.id
      update
    else
      insert
    end
  end

  def album
    Album.find(album_id)
  end

  private
  def update
    sql = <<-SQL
      UPDATE songs
      SET title=$1, album_id=$2
      WHERE id=$3
    SQL
    result = exec(sql, [title, album_id, id])
    self
  end

  def insert
    sql = <<-SQL
      INSERT INTO songs
      (title, album_id)
      VALUES
      ($1, $2)
      returning id
    SQL

    result = exec(sql, [title, album_id])
    self.id = result[0]["id"]
    self
  end

  def exec(sql, args=[])
    self.class.exec(sql, args)
  end
end
