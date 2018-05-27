require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)

    end

    sql2 = <<-SQL
      SELECT * FROM students
      WHERE name = ?
    SQL

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    @name = student.name
    @grade = student.grade
    student.save
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = Student.new(row[0], row[1], row [2])
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"

    row = DB[:conn].execute(sql, name)[0]
    student = Student.new_from_db(row)
    student
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
