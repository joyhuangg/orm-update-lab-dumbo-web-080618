require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)"
    DB[:conn].execute(sql)
  end

def self.drop_table
  sql = "DROP TABLE students"
  DB[:conn].execute(sql)
end

def save
  to_save = <<-SQL
    INSERT INTO students (name, grade)
    VALUES ("#{self.name}", "#{self.grade}")
  SQL
  if self.id
    update
  else
    DB[:conn].execute(to_save)
    instance = <<-SQL
    SELECT last_insert_rowid()
    FROM students
    SQL
    self.id = DB[:conn].execute(instance)[0][0]
  end
  Student.new(self.name, self.grade, self.id)
end

def self.create(name, grade)
  student = Student.new(name, grade)
  student.save
  student
end

def self.new_from_db(row)
  # create a new Student object given a row from the database
  student = Student.new(row[1], row[2], row[0])
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM students
    WHERE name = "#{name}"
    LIMIT 1;
  SQL
  Student.new_from_db(DB[:conn].execute(sql).flatten)
end

def update
  to_update = <<-SQL
    UPDATE students
    SET name="#{self.name}",
    grade="#{self.grade}"
    WHERE id = "#{self.id}";
  SQL
  DB[:conn].execute(to_update)
end

end
