require_relative 'commands/song_commands.rb'
require_relative 'commands/room_and_quote_commands.rb'
require_relative 'commands/other_commands.rb'

module Commands
  include SongCommands
  include RoomAndQuoteCommands
  include OtherCommands

  def set_commands
    set_song_commands(@bot)
    set_room_and_quote_commands(@bot)
    set_other_commands(@bot)
  end
end