class Bitmap

  def hue_customcolor(rules_string)
    return if rules_string.nil? || rules_string == "nil"
    if rules_string.include?("&")
      rules_string.split("&").each do |part|
        part = part.strip
        next if part.empty?
        hue_customcolor(part)
      end
      return
    end
    rules = rules_string.split("|").map do |str|
      parts = str.split(".")
      {
        from: parts[0].split.map(&:to_f),
        to: parts[1].split.map(&:to_f)
      }
    end
    width.times do |x|
      height.times do |y|
        color = get_pixel(x, y)
        next if color.alpha == 0
        r, g, b = color.red.to_f, color.green.to_f, color.blue.to_f
        # Avoid division by zero
        r = 10 if r <= 10
        g = 10 if g <= 10
        b = 10 if b <= 10

        min_distance = Float::INFINITY
        closest_rule = nil

        rules.each do |rule|
          from = rule[:from]
          # Avoid division by zero
          from[0] = 10 if from[0] <= 10
          from[1] = 10 if from[1] <= 10
          from[2] = 10 if from[2] <= 10
          dist = (r - from[0])**2 + (g - from[1])**2 + (b - from[2])**2
          if dist < min_distance
            min_distance = dist
            closest_rule = rule
          end
        end

        next unless closest_rule

        from = closest_rule[:from]
        to = closest_rule[:to]
        # Avoid multiplication by zero
        to[0] = 10 if to[0] <= 10
        to[1] = 10 if to[1] <= 10
        to[2] = 10 if to[2] <= 10
        r_factor = r / from[0]
        g_factor = g / from[1]
        b_factor = b / from[2]

        adjusted_r = (to[0] * r_factor).clamp(0, 255)
        adjusted_g = (to[1] * g_factor).clamp(0, 255)
        adjusted_b = (to[2] * b_factor).clamp(0, 255)
        set_pixel(x, y, Color.new(adjusted_r.to_i, adjusted_g.to_i, adjusted_b.to_i, color.alpha))
      end
    end
  end


  def update_shiny_cache(dex_number, name)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
    end

    return unless Dir.exist?(shiny_directory)

    # browse files in shiny_directory
    Dir.foreach(shiny_directory) do |file|
      next if file == "." || file == ".." # Ignorer les entrées spéciales
      file_path = File.join(shiny_directory, file)

      # delete files whose name contains "name"
      if File.file?(file_path) && file.include?(name)
        File.delete(file_path)
      end
    end
  end


  def hue_rename(dex_number, name, newname)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
    end

    return unless Dir.exist?(shiny_directory)

    Dir.entries(shiny_directory).each do |file|
      next unless file.include?(name) && file.end_with?(".png")

      old_path = "#{shiny_directory}/#{file}"
      new_file = file.sub(name, newname)
      new_path = "#{shiny_directory}/#{new_file}"

      File.rename(old_path, new_path)
    end
  end


  def hue_changecolors(dex_number, bodyShiny, headShiny, alt = "")
    
    return if !bodyShiny && !headShiny
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
      shiny_file_path = "#{shiny_directory}/#{head_id}.#{body_id}"
      offsets = [SHINY_COLOR_OFFSETS[body_id], SHINY_COLOR_OFFSETS[head_id]]
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
      shiny_file_path = "#{shiny_directory}/#{dex_number}"
      offsets = [SHINY_COLOR_OFFSETS[dex_number]]
    end

    # Determine the destination folders
    shiny_file_path += alt + "_bodyShiny" if bodyShiny
    shiny_file_path += alt + "_headShiny" if headShiny
    shiny_file_path += alt +".png"
    if File.exist?(shiny_file_path)
      return
    end



    offset = offsets.compact.max_by { |o| o.keys.count }
    if !offset
      hue_change(GameData::Species.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
      return
    end
    onetime = true
    offset.keys.each do |version|
      value = offset&.dig(version)

      if value.is_a?(String) && onetime
        onetime = false
        hue_customcolor(GameData::Species.calculateCustomShinyHueOffset(dex_number, bodyShiny, headShiny))
        Dir.mkdir(shiny_directory) unless Dir.exist?(shiny_directory)
        self.save_to_png(shiny_file_path)
      elsif !value.is_a?(String)
        hue_change(GameData::Species.calculateShinyHueOffset(dex_number, bodyShiny, headShiny, version))
      end
    end
  end
end