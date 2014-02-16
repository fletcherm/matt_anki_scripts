require_rel '.'

class KnownVocabularyWordCounter
  include Constants
  WORDS_PER_CLOZE_NOTES = 2

  def run(database_filename)
    DatabaseConnector.connect(database_filename)

    number_of_vocabulaire_words = count_vocabulaire_words
    ap "Regular vocab words: #{number_of_vocabulaire_words}"

    number_of_vocabulaire_cloze_words = count_vocabulaire_cloze_words
    ap "Cloze vocab words: #{number_of_vocabulaire_cloze_words}"

    ap "Total: #{number_of_vocabulaire_words + number_of_vocabulaire_cloze_words}"
  end

  private
  def count_vocabulaire_cloze_words
    vocabulaire_cloze_model = ModelFinder.for_name(VOCABULAIRE_CLOZE_MODEL_NAME)
    vocabulaire_cloze_model_id = Utilities.model_id_for(vocabulaire_cloze_model)

    vocabulaire_cloze_notes_count = Note.where(mid: vocabulaire_cloze_model_id).count
    vocabulaire_cloze_notes_count / WORDS_PER_CLOZE_NOTES
  end

  def count_vocabulaire_words
    vocabulaire_model = ModelFinder.for_name(VOCABULAIRE_MODEL_NAME)
    vocabulaire_model_id = Utilities.model_id_for(vocabulaire_model)
    vocabulaire_model_revers_field_index = Utilities.model_field_index_for(vocabulaire_model, REVERS_FIELD_NAME)

    vocabulaire_notes = Note.where(mid: vocabulaire_model_id).select(:flds)
    notes_with_both_sides = vocabulaire_notes.select do |note|
      fields = Note.split_by_fields(note)
      reverse_field = fields[vocabulaire_model_revers_field_index]
      reverse_field.present?
    end.count
  end
end
