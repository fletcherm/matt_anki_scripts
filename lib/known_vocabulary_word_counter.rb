require_rel '.'

class KnownVocabularyWordCounter
  def run(database_filename)
    connect_to_database(database_filename)

    number_of_vocabulaire_words = count_vocabulaire_words
    ap "Regular vocab words: #{number_of_vocabulaire_words}"

    number_of_vocabulaire_cloze_words = count_vocabulaire_cloze_words
    ap "Cloze vocab words: #{number_of_vocabulaire_cloze_words}"

    ap "Total: #{number_of_vocabulaire_words + number_of_vocabulaire_cloze_words}"
  end

  private
  def count_vocabulaire_cloze_words
    vocabulaire_cloze_model = find_model_for('vocabulaire - cloze')
    vocabulaire_cloze_model_id = extract_model_id(vocabulaire_cloze_model)

    vocabulaire_cloze_notes_count = Note.where(mid: vocabulaire_cloze_model_id).count
    vocabulaire_cloze_notes_count / 2
  end

  def count_vocabulaire_words
    vocabulaire_model = find_model_for('vocabulaire')
    vocabulaire_model_id = extract_model_id(vocabulaire_model)
    vocabulaire_model_revers_field_index = extract_revers_field_index(vocabulaire_model)

    vocabulaire_notes = Note.where(mid: vocabulaire_model_id).select(:flds)
    notes_with_both_sides = vocabulaire_notes.select do |note|
      fields = note.flds.split("\u001F")
      reverse_field = fields[vocabulaire_model_revers_field_index]
      reverse_field.present?
    end.count
  end

  def find_model_for(desired_model_name)
    desired_model = Collection.models.find do |(model_id, model_configuration)|
      model_configuration['name'] == desired_model_name
    end

    if desired_model.nil?
      puts "Could not find a model named [#{desired_model_name}]"
      exit 3
    else
      desired_model
    end
  end

  def extract_model_id(model)
    model.first.to_i
  end

  def extract_revers_field_index(model)
    revers_field = model.last['flds'].find do |field|
      field['name'] == 'revers'
    end

    if revers_field.nil?
      puts "Could not find the [revers] field on the [vocabulaire] model."
      exit 4
    else
      revers_field['ord'].to_i
    end
  end

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
