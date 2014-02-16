require_rel '.'

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
    words = todays_words(todays_vocabulaire)
    words = remove_words_that_are_images(words)
    print_grouped_words(words)
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
    vocabulaire_model_id = Utilities.model_id_for(vocabulaire_model)
    Note.where(id: cards.map(&:nid)).where(mid: vocabulaire_model_id)
  end

  def reviews_for(start_time)
    Review.where('id >= ?', start_time).select(:cid).pluck(:cid)
  end

  def todays_words(vocabulaire_notes)
    vocabulaire_model_mot_field_index = Utilities.model_field_index_for(vocabulaire_model, WORD_FIELD_NAME)
    vocabulaire_notes.map do |note|
      fields = Note.split_by_fields(note)
      fields[vocabulaire_model_mot_field_index]
    end
  end

  def remove_words_that_are_images(words)
    words.reject { |word| word.match(IMAGE_CARD) }
  end

  def vocabulaire_model
    ModelFinder.for_name(VOCABULAIRE_MODEL_NAME)
  end

  def print_grouped_words(words)
    number_of_groups = words.size / GROUP_SIZE
    number_of_groups.times do
      puts header
      words = group_for(words)
      puts footer
      puts
    end
  end

  def group_for(words)
    words = words.dup
    GROUP_SIZE.times do
      word = words.delete_at(rand(words.size))
      puts word
    end
    words
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
