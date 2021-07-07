class Guide < ActiveRecord::Base
end

class CharacterNickname < ActiveRecord::Base
end

class StartingQuote < ActiveRecord::Base
  def self.random_line(line_no)
    StartingQuote.where(line: line_no).sample[:text]
  end
end 

class Character < ActiveRecord::Base
  def self.get(query_str)
    # Look for a direct match in character table
    basic_query_result = Character.find_by(name: query_str)
    return basic_query_result if basic_query_result

    # Else, look for a matching nickname and return the character record
    nickname_result = CharacterNickname.find_by(text: query_str)
    return Character.find_by(id: nickname_result[:character]) if nickname_result

    nil
  end

  def get_nicknames
    character_id = self[:id]
    nickname_records = CharacterNickname.where(character: character_id)
    nickname_records.map(&:text)
  end
end