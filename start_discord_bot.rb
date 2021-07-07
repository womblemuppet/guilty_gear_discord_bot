require 'active_record'
require 'active_support/all'
require 'date'
require 'uri'
require 'yaml'

require 'discordrb'

require_relative 'commands.rb'
require_relative 'discord_bot.rb'
require_relative 'models.rb'

DISCORD_ACTIVITY_TYPE_GAME = 0

def load_config
  configuration_file = File.read("./botconfig.yaml")
  return YAML.load(configuration_file)
end

def connect_to_db(config)
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: 'localhost',
    username: 'root',
    password: config['MYSQL_PASS'],
    database: 'guilty_gear'
  )
end

def main
  config = load_config()

  connect_to_db(config)

  bot = DiscordBot.new(config)
  bot.start()
end

main() if __FILE__ == $PROGRAM_NAME