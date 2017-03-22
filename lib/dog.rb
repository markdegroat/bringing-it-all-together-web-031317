require_relative "../config/environment.rb"
require "pry"

class Dog

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    @id = nil
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
      SQL
    DB[:conn].execute(sql)
  end

  def save

    if self.id
      self.update
      self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end
  end

  def self.create(attributes)

    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row) #row is an array
    attributes = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    dog = Dog.new(attributes)
    dog.id = row[0]
    dog

  end

  def self.find_by_id_OLD(id)
    # find the dog in the database given a name
    # return a new instance of the Dog class
    sql = <<-SQL
        SELECT *
        FROM dogs
        where id = ?
        LIMIT 1
        SQL
    DB[:conn].execute(sql, id).collect do |row|#if we weren't limiting one in the sql query, then we would need to only grab the end.first value
      self.new_from_db(row)
    end.first #this end.first means end and return the FIRST value
   end


  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)
    #binding.pry
    attributes = {
      :id => result[0][0],
      :name => result[0][1],
      :breed => result[0][2]
    }
    dog = Dog.new(attributes)
    dog.id = attributes[:id]
    dog
  end
  def self.find_by_name(name)
    # find the dog in the database given a name
    # return a new instance of the Dog class
    sql = <<-SQL
        SELECT *
        FROM dogs
        where name = ?
        LIMIT 1
        SQL
    DB[:conn].execute(sql, name).map do |row|#if we weren't limiting one in the sql query, then we would need to only grab the end.first value
      self.new_from_db(row)
    end.first #this end.first means end and return the FIRST value
  end
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      #binding.pry
      dog_data = dog[0]
      attributes = {
        :id => dog_data[0],
        :name => dog_data[1],
        :breed => dog_data[2]

      }
      dog = Dog.new(attributes)
      dog.id = attributes[:id]
    else

      dog = self.create({name: name, breed: breed})
    end
    dog
  end 






end
