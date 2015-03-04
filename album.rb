class Album
  attr_accessor :id, :name, :artist_id

  def self.exec(sql, args=[])
    DBConnection.instance.exec(sql, args)
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM albums
    SQL

    results = exec(sql)
    results.map do |row|
      new(row)
    end
  end

  def self.find(id)
    sql = <<-SQL
      SELECT *
      FROM albums
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

  def artist
    Artist.find(artist_id)
  end

  def songs
    sql = <<-SQL
      SELECT songs.*
      FROM songs
      JOIN albums
      ON albums.id = songs.album_id
      WHERE songs.album_id = $1
    SQL

    results = exec(sql, [id])
    results.map do |row|
      Song.new(row)
    end
  end

  private
  def update
    sql = <<-SQL
      UPDATE albums
      SET name=$1, artist_id=$2
      WHERE id=$3
    SQL
    results = exec(sql, [name, artist_id, id])
    self
  end

  def insert
    sql = <<-SQL
      INSERT INTO albums
      (name, artist_id)
      VALUES
      ($1, $2)
      returning id
    SQL

    result = exec(sql, [name, artist_id])
    self.id = result[0]["id"]
    self
  end

  def exec(sql, args=[])
    self.class.exec(sql, args)
  end
end
