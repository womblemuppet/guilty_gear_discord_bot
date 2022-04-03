class Character
  def initialize(*args, &block)
    @ar_rec = CharacterAR.new(*args, &block)
  end

  def self.get(query_str)
    # Look for a direct match in character table
    basic_query_result = CharacterAR.find_by(name: query_str)
    return basic_query_result if basic_query_result

    # Else, look for a matching nickname and return the character record
    nickname_result = CharacterNickname.find_by(text: query_str)
    return CharacterAR.find_by(id: nickname_result[:character]) if nickname_result

    return nil
  end

  def self.random_character
    CharacterAR.all.sample
  end

  def get_nicknames
    character_id = @ar_rec[:id]
    nickname_records = CharacterNickname.where(character: character_id)
    nickname_records.map(&:text)
  end

  def [](key)
    @ar_rec[key]
  end

  def []=(key, value)
    @ar_rec[key] = value
  end

  def save
    @ar_rec.save
  end
end

class CharacterAR < ActiveRecord::Base
  self.table_name = "characters"
end