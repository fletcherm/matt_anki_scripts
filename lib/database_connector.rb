module DatabaseConnector
  module_function
  def validate_database_file(database_filename)
    if !File.exist?(database_filename)
      puts "Could not find the given Anki database file: [#{database_filename}]."
      exit 2
    end
  end

  def connect(database_filename)
    validate_database_file(database_filename)
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: database_filename)
  end
end
