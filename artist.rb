class Artist
  attr_accessor :id, :name

  def self.exec(sql, args=[])
    DBConnection.instance.exec(sql, args)
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM artists
    SQL

    results = exec(sql)
    results.map do |row|
      new(row)
    end
  end

  def self.find(id)
    sql = <<-SQL
      SELECT *
      FROM artists
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

  def albums
    sql = <<-SQL
      SELECT albums.*
      FROM albums
      JOIN artists
      ON artists.id = albums.artist_id
      WHERE albums.artist_id = $1
    SQL

    results = exec(sql, [id])
    results.map do |row|
      Album.new(row)
    end
  end

  private
  def update
    sql = <<-SQL
      UPDATE artists
      SET name=$1
      WHERE id=$2
    SQL
    result = exec(sql, [name, id])
    self
  end

  def insert
    sql = <<-SQL
      INSERT INTO artists
      (name)
      VALUES
      ($1)
      returning id
    SQL

    result = exec(sql, [name])
    self.id = result[0]["id"]
    self
  end

  def exec(sql, args=[])
    self.class.exec(sql, args)
  end
end
