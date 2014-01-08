require_rel '.'

class KnownVocabularyWordCounter
  def run(database_filename)
    connect_to_database(database_filename)

    p Collection.first
  end

  private
  def validate_database_file(database_filename)
    if !File.exist?(database_filename)
      puts "Could not find the given Anki database file: [#{database_filename}]."
      exit 2
    end
  end

  def connect_to_database(database_filename)
    validate_database_file(database_filename)
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: database_filename)
  end
end
