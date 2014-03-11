class WordsReviewedToday
  include Constants
  START_OF_DAY_OFFSET = 3
  GROUP_SIZE = 5
  IMAGE_CARD = /^<img/

  def run(database_filename)
    DatabaseConnector.connect(database_filename)

    start_time = start_of_today
    todays_cards = cards_for(start_time)

    todays_vocabulaire = vocabulaire_cards_in(todays_cards)
    words = todays_vocabulaire_words(todays_vocabulaire)

    todays_vocabulaire_cloze = vocabulaire_cloze_cards_in(todays_cards)
    words += todays_vocabulaire_cloze_words(todays_vocabulaire_cloze)

    todays_grammaire = grammaire_cards_in(todays_cards)
    grammaire = grammaire_examples_in(todays_grammaire)

    print_grouped_words(words.flatten, grammaire)
  end

  private
  def start_of_today
    now = DateTime.now.to_s
    today = DateTime.parse(now.split('T').first)
    to_epoch_milliseconds(today + START_OF_DAY_OFFSET.hours)
  end

  def cards_for(start_time)
    todays_reviews = reviews_for(start_time)
    Card.find(todays_reviews)
  end

  def vocabulaire_cards_in(cards)
    notes_for_model(vocabulaire_model, cards)
  end

  def vocabulaire_cloze_cards_in(cards)
    notes_for_model(vocabulaire_cloze_model, cards)
  end

  def grammaire_cards_in(cards)
    notes_for_model(grammaire_cloze_model, cards)
  end

  def notes_for_model(model, cards)
    model_id = Utilities.model_id_for(model)
    Note.where(id: cards.map(&:nid)).where(mid: model_id)
  end

  def reviews_for(start_time)
    Review.where('id >= ?', start_time).select(:cid).pluck(:cid)
  end

  def todays_vocabulaire_words(vocabulaire_notes)
    vocabulaire_model_mot_field_index = Utilities.model_field_index_for(vocabulaire_model, WORD_FIELD_NAME)
    words = vocabulaire_notes.map do |note|
      fields = Note.split_by_fields(note)
      fields[vocabulaire_model_mot_field_index]
    end
    remove_words_that_are_images(words)
  end

  def todays_vocabulaire_cloze_words(vocabulaire_cloze_notes)
    vocabulaire_cloze_model_cloze_field_index = Utilities.model_field_index_for(vocabulaire_cloze_model, VOCABULAIRE_CLOZE_FIELD_NAME)
    clozes = vocabulaire_cloze_notes.map do |note|
      fields = Note.split_by_fields(note)
      fields[vocabulaire_cloze_model_cloze_field_index]
    end
    extract_words_from_vocabulaire_cloze_field(clozes)
  end

  def grammaire_examples_in(grammaire_cloze_notes)
    grammaire_cloze_model_cloze_field_index = Utilities.model_field_index_for(grammaire_cloze_model, GRAMMAIRE_CLOZE_FIELD_NAME)
    grammaire_cloze_notes.map do |note|
      fields = Note.split_by_fields(note)
      fields[grammaire_cloze_model_cloze_field_index]
    end
  end

  def extract_words_from_vocabulaire_cloze_field(clozes)
    words = clozes.inject([]) do |words, cloze|
      cloze.scan(/{{c\d+::([[:alpha:]]+)}}/).each do |word|
        words << word.first.downcase
      end
      words
    end
    words.uniq
  end

  def vocabulaire_model
    ModelFinder.for_name(VOCABULAIRE_MODEL_NAME)
  end

  def vocabulaire_cloze_model
    ModelFinder.for_name(VOCABULAIRE_CLOZE_MODEL_NAME)
  end

  def grammaire_cloze_model
    ModelFinder.for_name(GRAMMAIRE_CLOZE_MODEL_NAME)
  end

  def remove_words_that_are_images(words)
    words.reject { |word| word.match(IMAGE_CARD) }
  end

  def print_grouped_words(words, grammaire)
    number_of_groups = words.size / GROUP_SIZE
    number_of_groups.times do
      puts header
      puts group_for(words)
      puts selection_from(grammaire)
      puts footer
      puts
    end
  end

  def group_for(words)
    GROUP_SIZE.times.map do
      selection_from(words)
    end
  end

  def selection_from(set)
    set[rand(set.size)]
  end

  def header
    '=' * 10
  end
  alias_method :footer, :header

  # thanks Anthony DeSimone
  # http://stackoverflow.com/a/13148978
  def to_epoch_milliseconds(date)
    (date.to_f * 1000).to_i
  end
end
