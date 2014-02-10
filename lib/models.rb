# See https://gist.github.com/sartak/3921255
# for an Anki database schema reference
# big thanks to sartak !
# https://github.com/sartak

require 'json'

class Card < ActiveRecord::Base
  self.table_name = 'cards'

  # Anki doesn't use single table inheritance, and I have no
  # intention to use it. The inheritance column name from the
  # Rails docs will work well enough for us.
  self.inheritance_column = 'zoink'
end

class Collection < ActiveRecord::Base
  self.table_name = 'col'

  def self.models
    JSON.parse(Collection.first.models)
  end
end

class Note < ActiveRecord::Base
  self.table_name = 'notes'

  FLD_SENTINEL = "\u001F"

  def self.split_by_fields(note)
    note.flds.split(FLD_SENTINEL)
  end
end

class Review < ActiveRecord::Base
  self.table_name = 'revlog'
end
