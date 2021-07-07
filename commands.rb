class DiscordBot
  def set_commands
    @bot.command(:random, min_args: 0, max_args: 0, description: 'Prints a random character emoji', usage: '!random') do
      random_character = Character.all.sample
      next get_emoji(random_character)
    end
    
    @bot.command(:room, min_args: 0, max_args: 0, description: 'Prints the room id', usage: '!room') do
      next "No room exists.\n#{playing_gg_string}" unless @general_data[:room_id].present?
    
      msg = <<~MSG
      #{@general_data[:room_id]}
      *Last changed #{@general_data[:room_id_last_updated]}*
      #{playing_gg_string}
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
      #{playing_gg_string}
      MSG
      
      next msg
    end
    
    @bot.command(:addguide, min_args: 2, description: 'Saves a guide for a character', usage: '!addguide character url') do |_event, character_name, raw_url, *description_words|
      description = description_words.join(" ")

      url = if raw_url[0..2] == "www"
        "http://" + raw_url
      else
        raw_url
      end

      next "Guide must be in URL format" unless url =~ URI.regexp
      next "Unknown character - #{character_name}" unless Character::get(character_name)

      new_guide = Guide.new(url: url, character: character[:id], description: description)
      new_guide.save!
      
      next "Saved guide for #{character[:name]}"
    end

    @bot.command(:getguides, min_args: 1, description: 'Gets all guides for a character', usage: '!getguides character') do |event, *character_name_words|
      character_name = character_name_words.join(" ")
      character = Character::get(character_name)
      next "Unknown character - #{character_name}" unless character

      guides_for_character = Guide.where(character: character[:id])
      next "No guides for #{character[:name]} yet" if guides_for_character.count == 0

      emoji = get_emoji(character)

      guides_for_character.each.with_index do |guide, i|
        new_embed = Discordrb::Webhooks::Embed.new(description: guide[:url])
        message = if guide[:description].presence
          "#{emoji}   **#{i + 1}**: #{guide[:description]}"
        else
          "#{emoji}   **#{i + 1}**: Guide #{i + 1} for #{guide[:character]}"
        end

        event.send_embed(message, new_embed)
      end
      
      next nil
    end

    @bot.command(:removeguide, min_args: 2, max_args: 2, description: 'Removes a guide', usage: '!removeguide character number') do |_event, character_name, id|
      character = Character::get(character_name)
      next "Unknown character - #{character_name}" unless character
      next "Number **#{id.inspect}** is not a number" unless id =~ /\d+/

      guides_for_character = Guide.where(character: character[:id])
      target_guide = guides_for_character[id.to_i - 1]
      next "Guide with number **#{id}** does not exist" unless target_guide

      target_guide.delete

      next "Removed guide **#{id}**. Run !getguides to get refreshed id numbers"
    end
      
    @bot.command(:getnicknames, min_args: 1, description: 'Prints all nicknames for a character', usage: '!getnicknames character') do |_event, *character_name_words|
      character_name = character_name_words.join(" ")
      character = Character::get(character_name)
      next "Unknown character - #{character_name}" unless character

      emoji = get_emoji(character)

      nicknames = character.get_nicknames()
      next "No nicknames for #{emoji}#{character[:name]}" if nicknames.empty?


      
      msg = <<~MSG
      Nicknames for #{emoji}#{character[:name]}
      #{nicknames.join("\n")}
      MSG
      
      next msg
    end
  end
end