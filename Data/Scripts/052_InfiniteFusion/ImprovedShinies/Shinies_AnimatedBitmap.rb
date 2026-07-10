# frozen_string_literal: true
class AnimatedBitmap
  def shiftCustomColors(rules)
    @bitmap.bitmap.hue_customcolor(rules)
  end

  SHINY_BASE_FOLDER = "Graphics/Battlers/Shiny/"
  def shiftAllColors(dex_number, bodyShiny, headShiny)
    # pratically the same as hue_changecolors but for the animated bitmap
    if isFusion(dex_number)
      return if !bodyShiny && !headShiny
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
    shiny_file_path += "_bodyShiny" if bodyShiny
    shiny_file_path += "_headShiny" if headShiny
    shiny_file_path += ".png"
    if File.exist?(shiny_file_path)
      @bitmap.bitmap = Bitmap.new(shiny_file_path)
      return
    end
    offset = offsets.compact.max_by { |o| o.keys.count }
    if !offset
      shiftColors(GameData::Species.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
      return
    end
    onetime = true
    offset.keys.each do |version|
      value = offset&.dig(version)

      if value.is_a?(String) && onetime
        onetime = false
        shiftCustomColors(GameData::Species.calculateCustomShinyHueOffset(dex_number, bodyShiny, headShiny))
        Dir.mkdir(shiny_directory) unless Dir.exist?(shiny_directory)
        Dir.mkdir(shiny_directory) unless Dir.exist?(shiny_directory)
        @bitmap.bitmap.save_to_png(shiny_file_path)
      elsif !value.is_a?(String)
        shiftColors(GameData::Species.calculateShinyHueOffset(dex_number, bodyShiny, headShiny, version))
      end
    end
  end

end
