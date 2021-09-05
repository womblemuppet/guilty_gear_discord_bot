class DiscordBot
  def initialize(config)
    @bot = Discordrb::Commands::CommandBot.new(token: config['TOKEN'], client_id: config['CLIENT_ID'], prefix: '!', intents: :all)
    puts "Started GG bot at #{Time.now.strftime('%d %b - %H:%M:%S')}!"
    
    @general_data = {
      room_id: "",
      room_id_last_updated: nil
    }

    @number_of_goodbots = 0
  end

  def start
    set_commands()
    @bot.run()
  end

  def get_emoji(character)
    @bot.find_emoji(character[:name].downcase)
  end

  def users
    @bot.users.map { |u| u[1] }
  end

  def get_nickname_on_server(server)
    member = @bot.bot_user.on(server)
    return member.nickname
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

  def choose_line_number_for_quote(quote)
    return case quote.length
    when 0..8
      3
    when 9..15
      2
    when 16..25
      1
    else
      0
    end
  end
end