module RoomAndQuoteCommands
  DISCORD_ACTIVITY_TYPE_GAME = 0

  def set_room_and_quote_commands(bot)
    bot.command(:room, min_args: 0, max_args: 0, description: 'Prints the room id', usage: '!room') do |event|
      logger.log_event(event)

      next "No room exists.\n#{playing_gg_string}" unless @state[:room_id].present?
    
      msg = <<~MSG
      #{@state[:room_id]}
      *Last changed #{@state[:room_id_last_updated]}*
      MSG
      
      next msg
    rescue => e
      @logger.log_error(e)
      next ""
    end
    
    bot.command(:setroom, min_args: 1, max_args: 1, description: 'Sets the room id', usage: '!room room_id')  do |event, new_room_id|
      logger.log_event(event)

      @state[:room_id] = new_room_id
      @state[:room_id_last_updated] = Time.now.strftime('%H:%M')
    
      mentions_lines = users_on_discord.sum { |user| "#{user.mention}\n" }
      
      msg = <<~MSG
      Room id set to #{@state[:room_id]}
      #{generate_starting_quote}
      #{mentions_lines}
      MSG
      
      next msg
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:startingquote, min_args: 0, max_args: 0, description: 'Prints an Arc-sys approved round start message', usage: '!startingquote') do |event|
      logger.log_event(event)

      next generate_starting_quote()
    end

    bot.command(:addquote, min_args: 1, description: "Adds a quote to the pool for !startingquote . If a digit is the last character it will set which line of the quote it will become when picked", usage: "!addquote words [number]") do |event, *args|
      logger.log_event(event)

      line_number_specified = args.last =~ /[1-4]/

      if line_number_specified
        *quote_words, line_number = args
        line_number = line_number.to_i - 1

        quote = quote_words.join(" ")
      else
        quote_words = args
        quote = quote_words.join(" ")
        line_number = choose_line_number_for_quote(quote)
      end
      
      new_quote = StartingQuote.new(line: line_number, text: quote)
      new_quote.save()

      next "Added \"#{quote}\" to the quote pool (chose line #{line_number + 1})"
    rescue => e
      @logger.log_error(e)
      next ""
    end
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

end
