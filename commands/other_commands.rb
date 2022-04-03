module OtherCommands
  def set_other_commands(bot)
    bot.command(:random, min_args: 0, max_args: 0, description: 'Prints a random character emoji', usage: '!random') do |event|
      logger.log_event(event)

      random_character = Character.random_character()
      next get_emoji(random_character)
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:goodbot, max_args: 0, description: 'Pet the bot', usage: '!goodbot') do |event, *args|
      logger.log_event(event)

      nickname = get_nickname_on_server(event.server)

      @number_of_goodbots_since_sleep += 1
      bot_metadata = BotMetadata.first
      bot_metadata[:total_good_bots] += 1
      bot_metadata.save()

      time_str = -> (n) { n == 1 ? "time" : "times" }
      sleep_time_str = time_str.call(@number_of_goodbots_since_sleep)
      total_time_str = time_str.call(bot_metadata[:total_good_bots])

      next "#{nickname} smiles proudly. They have been called a good bot **#{@number_of_goodbots_since_sleep}** #{sleep_time_str} since waking up (**#{bot_metadata[:total_good_bots]}** #{total_time_str} total)"
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.message() do |event|
      username = event.message.author.display_name
      next unless username == "Barcode"

      next unless DateTime.now.hour.between?(1, 5)

      msg = <<~MSG
      Shaun...
      #{go_to_sleep_strings.sample}
      MSG

      logger.log("would be sending:\n#{msg}")
      # event.respond(msg)
    rescue => e
      @logger.log_error(e)
      next ""
    end
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