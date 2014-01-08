# See https://gist.github.com/sartak/3921255
# for an Anki database schema reference

require 'json'

class Collection < ActiveRecord::Base
  self.table_name = 'col'

  def self.models
    JSON.parse(Collection.first.models)
  end
end

class Note < ActiveRecord::Base
end
