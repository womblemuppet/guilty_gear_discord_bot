    
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
