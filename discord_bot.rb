class DiscordBot
  DISCORD_ACTIVITY_TYPE_GAME = 0

  def initialize(config)
    options = { 
      token: config['TOKEN'],
      client_id: config['CLIENT_ID'],
      prefix: '!',
      intents: :all
    }

    @bot = Discordrb::Commands::CommandBot.new(options)
    puts "Started GG bot at #{Time.now.strftime('%d %b - %H:%M:%S')}!"
    
    @general_data = {
      room_id: "",
      room_id_last_updated: nil
    }

    @number_of_goodbots_since_sleep = 0
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
      next true if games.any? { |game| game.name == "GUILTY GEAR -STRIVE-" }
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
    case quote.length
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

  def go_to_sleep_strings
    [
      "https://www.webmd.com/sleep-disorders/benefits-sleep-more",
      "https://www.sclhealth.org/blog/2018/09/the-benefits-of-getting-a-full-night-sleep/",
      "https://www.healthline.com/nutrition/10-reasons-why-good-sleep-is-important",
      "https://www.verywellhealth.com/top-health-benefits-of-a-good-nights-sleep-2223766",
      "https://healthysleep.med.harvard.edu/healthy/matters/benefits-of-sleep",
      "https://www.healthline.com/health/sleep-deprivation/effects-on-body",
      "https://www.nhs.uk/live-well/sleep-and-tiredness/why-lack-of-sleep-is-bad-for-your-health/",
      "https://www.medicalnewstoday.com/articles/307334",
      "https://www.webmd.com/sleep-disorders/features/10-results-sleep-loss",
      "https://www.hopkinsmedicine.org/health/wellness-and-prevention/the-effects-of-sleep-deprivation"
    ]
  end

end