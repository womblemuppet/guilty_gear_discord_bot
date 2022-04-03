class Guide < ActiveRecord::Base
end

class CharacterNickname < ActiveRecord::Base
end

class Song < ActiveRecord::Base
end

class Album < ActiveRecord::Base
end

class SongRating < ActiveRecord::Base
end

class BotMetadata < ActiveRecord::Base
  self.table_name = "bot_metadata"
end
