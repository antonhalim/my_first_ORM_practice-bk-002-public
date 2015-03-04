module HacktiveRecord
  class Base
    def self.inherited(base)
      base.class_eval do
        attr_accessor *column_names
      end
    end

    def self.belongs_to(relationship)
      klass = self.get_class(relationship.to_s.capitalize)
      define_method relationship do
        klass.find(public_send("#{relationship}_id"))
      end
    end

    def self.get_class(klass)
      klass = Object.const_get(klass)
    rescue NameError
      require klass.to_s.downcase
      klass = Object.const_get(klass)
    end

    def self.has_many(relationship)
      class_name = Inflecto.singularize(relationship.to_s).capitalize
      klass = self.get_class(class_name)

      singular_self = self.name.downcase

      define_method relationship do
        sql = <<-SQL
          SELECT #{relationship}.*
          FROM #{relationship}
          JOIN #{self.class.table_name}
          ON #{self.class.table_name}.id = #{relationship}.#{singular_self}_id
          WHERE #{relationship}.#{singular_self}_id = $1
        SQL

        results = exec(sql, [id])
        results.map do |row|
          klass.new(row)
        end
      end
    end

    def self.table_name
      Inflecto.pluralize(self.name).downcase
    end

    def self.column_names
      sql = <<-SQL
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name='#{table_name}'
      SQL

      exec(sql).flat_map{|column| column.values}.map(&:to_sym)
    end

    def self.exec(sql, args=[])
      DBConnection.instance.exec(sql, args)
    end

    def self.all
      sql = <<-SQL
        SELECT *
        FROM #{table_name}
      SQL

      results = exec(sql)
      results.map do |row|
        new(row)
      end
    end

    def self.find(id)
      sql = <<-SQL
        SELECT *
        FROM #{table_name}
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

    private
    def exec(sql, args=[])
      self.class.exec(sql, args)
    end

    def safe_columns
      self.class.column_names - [:id]
    end

    def insert
      values = safe_columns.map{|column| public_send(column)}
      placeholders = (1..values.count).map{|p| "$#{p}"}.join(',')
      sql = <<-SQL
        INSERT INTO #{self.class.table_name}
        (#{safe_columns.join(",")})
        VALUES
        (#{placeholders})
        returning id
      SQL

      result = exec(sql, values)
      self.id = result[0]["id"]
      self
    end

    def update
      set_string = safe_columns.map.with_index(1) do |column, i|
        "#{column}=$#{i}"
      end

      values = safe_columns.map {|column| public_send(column)}
      sql = <<-SQL
        UPDATE #{self.class.table_name}
        SET #{set_string.join(",")}
        WHERE id=#{id}
      SQL
      results = exec(sql, values)
      self
    end

  end
end
