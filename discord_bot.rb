require_relative 'commands.rb'
require_relative 'logger.rb'
require_relative 'models/models.rb'
require_relative 'models/character.rb'
require_relative 'models/starting_quote.rb'

class DiscordBot
  include Commands

  attr_reader :logger

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

    @logger = DiscordBotLogger.new()
  end

  def start
    set_commands()
    @logger.log_bot_start()
    @bot.run()
  end

end