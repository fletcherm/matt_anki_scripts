require_rel '.'

class WordsReviewedToday
  START_OF_DAY_OFFSET = 3

  def run(database_filename)
    DatabaseConnector.connect(database_filename)

    start_time = start_of_today
    todays_cards = cards_for(start_time)
    todays_vocabulaire = vocabulaire_cards_in(todays_cards)
    todays_words = words_for(todays_vocabulaire)
    ap todays_words
  end

  private
  def start_of_today
    now = DateTime.now.to_s
    today = DateTime.parse(now.split('T').first)
    to_epoch_milliseconds(today + START_OF_DAY_OFFSET.hours)
  end

  def cards_for(start_time)
    todays_reviews = reviews_for(start_time)
    cards  = Card.find(todays_reviews)
  end

  def vocabulaire_cards_in(cards)
    vocabulaire_model = ModelFinder.for_name('vocabulaire')
    vocabulaire_model_id = Utilities.model_id_for(vocabulaire_model)
    Note.where(id: cards.map(&:nid)).where(mid: vocabulaire_model_id)
  end

  def reviews_for(start_time)
    Review.where('id >= ?', start_time).select(:cid).pluck(:cid)
  end

  def todays_words(vocabulaire_notes)
  end

  # thanks Anthony DeSimone
  # http://stackoverflow.com/a/13148978
  def to_epoch_milliseconds(date)
    (date.to_f * 1000).to_i
  end
end
