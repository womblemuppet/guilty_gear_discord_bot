module OtherCommands
  def set_other_commands(bot)
    bot.command(:random, min_args: 0, max_args: 0, description: 'Prints a random character emoji', usage: '!random') do |event|
      logger.log_event(event)

      random_character = Character.random_character()
      next get_emoji(random_character[:name].downcase)
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:goodbot, max_args: 0, description: 'Pet the bot', usage: '!goodbot') do |event, *args|
      logger.log_event(event)

      nickname = get_nickname_on_server(event.server)

      @state[:number_of_goodbots_since_sleep] += 1
      bot_metadata = BotMetadata.first
      bot_metadata[:total_good_bots] += 1
      bot_metadata.save()

      time_str = -> (n) { n == 1 ? "time" : "times" }
      sleep_time_str = time_str.call(@state[:number_of_goodbots_since_sleep])
      total_time_str = time_str.call(bot_metadata[:total_good_bots])

      next "#{nickname} smiles proudly. They have been called a good bot **#{@state[:number_of_goodbots_since_sleep]}** #{sleep_time_str} since waking up (**#{bot_metadata[:total_good_bots]}** #{total_time_str} total)"
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:goodbort, max_args: 0, description: 'Pet the bort', usage: '!goodbort') do |event, *args|
      logger.log_event(event)

      nickname = get_nickname_on_server(event.server)

      next "#{nickname} smiles proudly. They have been called a good bort"
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.message() do |event|
      event_message = event.message.content

      is_dooming_about_anji = @anti_doomer.is_dooming_about_anji?(event_message)

      if is_dooming_about_anji
        update_last_doom_result = update_last_doom()

        seconds_since_last_doom = Time.now - update_last_doom_result[:previous_doom_time]
        time_since_last_doom = Duration.new(seconds_since_last_doom)
        time_str_since_last_doom = if time_since_last_doom.weeks > 0
          time_since_last_doom.format("%w weeks %d days %h hours %m minutes %s seconds")
        elsif time_since_last_doom.days > 0
          time_since_last_doom.format("%d days %h hours %m minutes %s seconds")
        else
          time_since_last_doom.format("%h hours %m minutes %s seconds")
        end

        msg = <<~MSG
        BEEP BOOP
        **PLEASE REFRAIN FROM DOOMING ABOUT ANJI MITO**
        **ALL MESSAGES REGARDING ANJI MITO MUST BE SUFFICIENTLY POSITIVE**

        Time since last infraction (#{time_str_since_last_doom})
        MSG

        event.respond(msg)
      end
    rescue => e
      @logger.log_error(e)
    end

    bot.command(:gitpull, min_args: 1, max_args: 1, description: 'Pull latest changes', usage: '!gitpull admin_password') do |event, password|
      logger.log_event(event)
      next "Invalid password you goober" unless password.strip == @state[:config]["ADMIN_PASSWORD"]

      pull_result = `git pull`
      next "Pulled: #{pull_result}"
    rescue => e
      @logger.log_error(e)
      next ""
    end
  end

  def get_emoji(emoji_name)
    @bot.find_emoji(emoji_name)
  end

  def users
    @bot.users.map { |u| u[1] }
  end

  def get_nickname_on_server(server)
    member = @bot.bot_user.on(server)
    return member.nickname
  end

  def update_last_doom
    bot_metadata = BotMetadata.first

    previous_doom_time = bot_metadata[:last_doomed]
    bot_metadata[:total_dooms] += 1
    bot_metadata[:last_doomed] = DateTime.now()
    bot_metadata.save!()

    return { previous_doom_time: previous_doom_time }
  end

end