module SongCommands
  def set_song_commands(bot)
    bot.command(:albums, max_args: 0, description: 'List all albums by name', usage: '!albums') do |event|
      logger.log_event(event)

      albums = Album.all.pluck(:name)
      
      msg = <<~MSG
      Albums:
      #{albums.join("\n")}
      MSG
      
      next msg
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:songs, min_args: 1, description: 'List all songs for an album', usage: '!songs album') do |event, *album_name_args|
      logger.log_event(event)

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
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:song, description: 'Lists a song and some details', usage: '!song song') do |event, *song_title_args|
      logger.log_event(event)

      songs_and_ratings = Song.select("*").joins("LEFT JOIN song_ratings sr ON sr.song = songs.id")

      song_title = song_title_args.join(" ")
      song = songs_and_ratings.find_by_title(song_title)

      next "No song exists with that name" unless song

      album = Album.find_by_id(song[:album])
      average_rating = songs_and_ratings.where(title: song_title).average(:rating)

      unless song[:rating]
        msg = <<~MSG
        Song **#{song[:title]}** from **#{album[:name]}** - No rating
        MSG
        
        next msg
      end

      average_ratings = songs_and_ratings.group(:song).average(:rating)

      ratings = average_ratings.inject([]) do |acc, (song_id, rating)|
        next acc unless rating
        next [*acc, { song_id: song_id, average_rating: rating.to_f}]
      end.sort_by { |rating| rating[:average_rating] }.reverse
      # Would use AR order but was running into sql_mode=only_full_group_by errors

      index = ratings.find_index { |rating| rating[:song_id] == song[:song] }

      min_index = (index - 4).clamp(0, ratings.length - 1)
      max_index = (index + 4).clamp(0, ratings.length - 1)

      target_and_peripheral_rating_lines = (min_index .. max_index).inject([]) do |acc, i|
        song_title = Song.find_by_id(ratings[i][:song_id])[:title]
        average_rating = ratings[i][:average_rating]

        rating_text = "#{song_title} - #{average_rating}"
        
        if i == index
          # Bold the rating text for the selected song
          bolded_rating_text = "**#{rating_text}**"
          next [*acc, bolded_rating_text]
        else
          next [*acc, rating_text]
        end
      end

      msg = <<~MSG
      Song **#{song[:title]}** from **#{album[:name]}**

      ...
      #{target_and_peripheral_rating_lines.join("\n")}
      ...
      MSG
      
      next msg
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:ratesong, min_args: 2, description: 'Rate a song', usage: '!ratesong song rating') do |event, *song_title_args, rating|
      logger.log_event(event)

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

      next "Gave \"#{song_title}\" a rating of #{rating}"
    rescue => e
      @logger.log_error(e)
      next ""
    end

    bot.command(:randomsong, description: 'Chooses a random song', usage: '!randomsong') do |event|
      logger.log_event(event)

      random_id = rand(Song.count)
      random_song = Song.where("id > ?", random_id).first
      album_name = Album.find_by_id(random_song[:album])[:name]

      next "You should listen to: #{random_song[:title]} from #{album_name}"
    rescue => e
      @logger.log_error(e)
      next ""
    end
  end

end