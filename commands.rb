class DiscordBot
  def set_commands
    @bot.command(:random, min_args: 0, max_args: 0, description: 'Prints a random character emoji', usage: '!random') do
      random_character = Character.random_character()
      next get_emoji(random_character)
    end
    
    @bot.command(:room, min_args: 0, max_args: 0, description: 'Prints the room id', usage: '!room') do
      next "No room exists.\n#{playing_gg_string}" unless @general_data[:room_id].present?
    
      msg = <<~MSG
      #{@general_data[:room_id]}
      *Last changed #{@general_data[:room_id_last_updated]}*
      MSG
      
      next msg
    end
    
    @bot.command(:setroom, min_args: 1, max_args: 1, description: 'Sets the room id', usage: '!room room_id')  do |_event, new_room_id|
      @general_data[:room_id] = new_room_id
      @general_data[:room_id_last_updated] = Time.now.strftime('%H:%M')
    
      mentions_lines = users_on_discord.sum { |user| "#{user.mention}\n" }
      
      msg = <<~MSG
      Room id set to #{@general_data[:room_id]}
      #{generate_starting_quote}
      #{mentions_lines}
      MSG
      
      next msg
    end

    @bot.command(:startingquote, min_args: 0, max_args: 0, description: 'Prints an Arc-sys approved round start message', usage: '!startingquote') do
      next generate_starting_quote()
    end

    @bot.command(:addquote, min_args: 1, description: "Adds a quote to the pool for !startingquote . If a digit is the last character it will set which line of the quote it will become when picked", usage: "!addquote words [number]") do |_event, *args|

      line_number_specified = args.last =~ /[1-4]/

      if line_number_specified
        *quote_words, line_number = args
        quote = quote_words.join(" ")
      else
        quote_words = args
        quote = quote_words.join(" ")
        line_number = choose_line_number_for_quote(quote)
      end
      
      new_quote = StartingQuote.new(line: line_number, text: quote)
      new_quote.save()

      next "Added \"#{quote}\" to the quote pool (chose line #{line_number + 1})"
    end
  
    @bot.command(:goodbot, max_args: 0, description: 'Pet the bot', usage: '!goodbot') do |event, *args|
      nickname = get_nickname_on_server(event.server)

      @number_of_goodbots_since_sleep += 1
      bot_metadata = BotMetadata.first
      bot_metadata[:total_good_bots] += 1
      bot_metadata.save()

      time_str = -> (n) { n == 1 ? "time" : "times" }
      sleep_time_str = time_str.call(@number_of_goodbots_since_sleep)
      total_time_str = time_str.call(bot_metadata[:total_good_bots])

      next "#{nickname} smiles proudly. They have been called a good bot **#{@number_of_goodbots_since_sleep}** #{sleep_time_str} since waking up (**#{bot_metadata[:total_good_bots]}** #{total_time_str} total)"
    end

    @bot.command(:albums, max_args: 0, description: 'List all albums by name', usage: '!albums') do
      albums = Album.all.pluck(:name)
      
      msg = <<~MSG
      Albums:
      #{albums.join("\n")}
      MSG
      
      next msg
    end

    @bot.command(:songs, description: 'List all songs for an album', usage: '!songs album') do |_event, *album_name_args|
      album_name = album_name_args.join(" ")
      album = Album.find_by_name(album_name)
      next "No album exists with that name" unless album

      songs_and_ratings = Song.select("*").joins("LEFT JOIN song_ratings sr ON sr.song = songs.id").order(rating: :desc)
      songs = songs_and_ratings.where(album: album[:id]).map { |song| "#{song[:title]} - #{song[:rating]}" }
      
      msg = <<~MSG
      Songs for #{album[:name]}:
      #{songs.join("\n")}
      MSG
      
      next msg
    end

    @bot.command(:song, description: 'Lists a song and some details', usage: '!song song') do |_event, *song_title_args|
      songs_and_ratings = Song.select("*").joins("LEFT JOIN song_ratings sr ON sr.song = songs.id").order(rating: :desc)

      song_title = song_title_args.join(" ")
      song = songs_and_ratings.find_by_title(song_title)
      next "No song exists with that name" unless song # should get similar words?

      album = Album.find_by_id(song[:album])
      average_rating = songs_and_ratings.where(title: song_title).average(:rating)

      if song[:rating]
        ratings = songs_and_ratings.group(:song).order(rating: :desc).average(:rating).inject([]) do |acc, (song_id, rating)|
          !rating ? acc : [*acc, { song_id: song_id, average_rating: rating.to_f}]
        end

        puts "ratings", ratings, "song[:id]", song[:song]

        index = ratings.find_index { |rating| rating[:song_id] == song[:song] }
        puts "index", index

        min_index = (index - 2).clamp(0, ratings.length - 1)
        max_index = (index + 2).clamp(0, ratings.length - 1)

        target_and_peripheral_ratings = (min_index .. max_index).inject([]) do |acc, i|
          song_title = Song.find_by_id(ratings[i][:song_id])[:title]
          average_rating = ratings[i][:average_rating]

          next [*acc, "**#{song_title} - #{average_rating}**"] if i == index
          next [*acc, "#{song_title} - #{average_rating}"]
        end

        msg = <<~MSG
        Song **#{song[:title]}** from **#{album[:name]}**

        ...
        #{target_and_peripheral_ratings.join("\n")}
        ...
        MSG
      else
        msg = <<~MSG
        Song **#{song[:title]}** from **#{album[:name]}** - No rating
        MSG
      end
      
      next msg
    end

    @bot.command(:ratesong, min_args: 2, description: 'Rate a song', usage: '!ratesong song rating') do |event, *song_title_args, rating|
      next "#{rating} is an invalid rating - please rate between 0 and 5 you muppet" unless rating =~ /\A[0-5](\.[0-9])?\z/ && (0..5).include?(rating.to_i)
      
      song_title = song_title_args.join(" ")
      song = Song.find_by_title(song_title)
      next "No song exists with that title" unless song

      username = event.message.author.display_name
      
      previous_rating = SongRating.find_by(username: username, song: song[:id])
      
      if previous_rating
        previous_rating[:rating] = rating
        previous_rating.save()
      else
        new_rating = SongRating.new(song: song[:id], username: username, rating: rating)
        new_rating.save()
      end

      next "Gave #{song_title} a rating of #{rating}"
    end

    # @bot.message() do |event|
    #   username = event.message.author.display_name
    #   next unless username == "Barcode"

    #   next unless DateTime.now.hour.between?(1, 5)

    #   msg = <<~MSG
    #   Shaun...
    #   #{go_to_sleep_strings.sample}
    #   MSG

    #   event.respond(msg)
    # end
  end
end