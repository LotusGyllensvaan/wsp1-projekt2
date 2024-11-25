require 'sqlite3'
require 'bcrypt'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS tasks')
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
    db.execute('CREATE TABLE tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                ongoing BOOLEAN NOT NULL,
                category TEXT)')

    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                password TEXT NOT NULL)')
  end

  def self.populate_tables
    password_hashed = BCrypt::Password.create("123")
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Admin", password_hashed])

    db.execute('INSERT INTO tasks (title, ongoing) VALUES ("Goon sesh", 1)')
    db.execute('INSERT INTO tasks (title, description, ongoing) VALUES ("Ägg", "Typ 5 ägg helt ärligt", 1)')
    db.execute('INSERT INTO tasks (title, description, ongoing) VALUES ("Träna", "20 sets 30 reps - jamaican spine extensions", 1)')
    db.execute('INSERT INTO tasks (title, description, ongoing) VALUES ("Kill", "German Assasinations", 0)')
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/tasks.sqlite')
    @db.results_as_hash = true
    @db
  end

end

Seeder.seed!