class DiscordBot
  def initialize(config)
    @bot = Discordrb::Commands::CommandBot.new(token: config['TOKEN'], client_id: config['CLIENT_ID'], prefix: '!', intents: :all)
    puts "Started GG bot at #{Time.now.strftime('%d %b - %H:%M:%S')}!"
    
    @general_data = {
      room_id: "",
      room_id_last_updated: nil
    }
  end

  def start
    set_commands()
    @bot.run()
  end

  def get_emoji(bot, character)
    @bot.find_emoji(character[:name].downcase)
  end

  def users
    @bot.users.map { |u| u[1] }
  end
  
  def users_on_discord
    users.reject { |user| user.bot_account? || user.status == :offline }
  end
  
  def people_playing_guilty_gear
    users_on_discord.select do |user|
      games = user.activities.select { |activity| activity.type == DISCORD_ACTIVITY_TYPE_GAME }
      next true if games.any?{ |game| game.name == "GUILTY GEAR -STRIVE-" }
    end
  end
  
  def playing_gg_string
    "Currently playing Guilty Gear: **#{people_playing_guilty_gear.count}**"
  end

  def generate_starting_quote
    <<~MSG
    **#{StartingQuote.random_line(0)}**
    **#{StartingQuote.random_line(1)}**
    **#{StartingQuote.random_line(2)}**
    **#{StartingQuote.random_line(3)}**
    MSG
  end
end