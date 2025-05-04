#object representing a sprite which saves its position in the tileset
class PIFSprite
  attr_accessor :type
  attr_accessor :head_id
  attr_accessor :body_id
  attr_accessor :alt_letter
  attr_accessor :local_path

  #types:
  # :AUTOGEN, :CUSTOM, :BASE
  def initialize(type, head_id, body_id, alt_letter = "")
    @type = type
    @head_id = head_id
    @body_id = body_id
    @alt_letter = alt_letter
    @local_path = nil
  end

  def dump_info()
    echoln "Type: #{@type}"
    echoln "Head: #{@head_id}"
    echoln "Body: #{@body_id}"
    echoln "Alt letter: #{@alt_letter}"
    echoln "Local path: #{@local_path}"
  end

  def equals(other_pif_sprite)
    return @type == other_pif_sprite.type &&
      @head_id == other_pif_sprite.head_id &&
      @body_id == other_pif_sprite.body_id &&
      @alt_letter == other_pif_sprite.alt_letter &&
      @local_path == other_pif_sprite.local_path
  end

  #little hack for old methods that expect a filename for a sprite
  def to_filename()
    case @type
    when :CUSTOM
      return "#{@head_id}.#{@body_id}#{@alt_letter}.png"
    when :AUTOGEN
      return "#{@head_id}.#{@body_id}.png"
    when :BASE
      return "#{@head_id}#{@alt_letter}.png"
    end
  end

  def setup_from_spritename(spritename, type)
    @type = type
    cleaned_name = spritename.gsub(".png", "")
    if cleaned_name =~ /(\d+)\.(\d+)([a-zA-Z]*)/
      head_id = $1
      body_id = $2
      alt_letter = $3
    end
    @head_id = head_id
    @body_id = body_id
    @alt_letter = alt_letter
  end

  def self.from_spritename(spritename, type)
    obj = allocate
    obj.send(:setup_from_spritename, spritename, type)
    obj
  end

end

def new_pif_sprite_from_dex_num(type, dexNum, alt_letter)
  body_id = getBodyID(dexNum)
  head_id = getHeadID(dexNum, body_id)
  return PIFSprite.new(type, head_id, body_id, alt_letter)
end

def pif_sprite_from_spritename(spritename, autogen = false)
  spritename = spritename.split(".png")[0] #remove the extension
  if spritename =~ /^(\d+)\.(\d+)([a-zA-Z]*)$/ # Two numbers with optional letters
    type = :CUSTOM
    head_id = $1.to_i # Head (e.g., "1" in "1.2.png")
    body_id = $2.to_i # Body (e.g., "2" in "1.2.png")
    alt_letter = $3 # Optional trailing letter (e.g., "a" in "1.2a.png")

  elsif spritename =~ /^(\d+)([a-zA-Z]*)$/ # One number with optional letters
    type = :BASE
    head_id = $1.to_i # Head (e.g., "1" in "1.png")
    alt_letter = $2 # Optional trailing letter (e.g., "a" in "1a.png")
  else
    echoln "Invalid sprite format: #{spritename}"
    return nil
  end
  type = :AUTOGEN if autogen
  return PIFSprite.new(type, head_id, body_id, alt_letter)
end
