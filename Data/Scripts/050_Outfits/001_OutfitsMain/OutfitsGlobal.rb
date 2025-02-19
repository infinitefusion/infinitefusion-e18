class PokemonGlobalMetadata
  attr_accessor :hats_data
  attr_accessor :hairstyles_data
  attr_accessor :clothes_data
  attr_accessor :accessories_data
end

def update_global_hats_list()
  file_path = Settings::HATS_DATA_PATH
  json_data = File.read(file_path)
  hat_data = HTTPLite::JSON.parse(json_data)

  $PokemonGlobal.hats_data = {}

  # Iterate through the JSON data and create Hat objects
  hat_data.each do |data|
    tags = data['tags'] ? data['tags'].split(',').map(&:strip) : []
    hat = Hat.new(
      data['id'],
      data['name'],
      data['description'],
      data['price'],
      tags
    )
    $PokemonGlobal.hats_data[hat.id] = hat
  end
end

def update_global_accessories_list()
  file_path = Settings::ACCESSORIES_DATA_PATH
  json_data = File.read(file_path)
  hat_data = HTTPLite::JSON.parse(json_data)

  $PokemonGlobal.hats_data = {}

  # Iterate through the JSON data and create Hat objects
  hat_data.each do |data|
    tags = data['tags'] ? data['tags'].split(',').map(&:strip) : []
    hat = Accessory.new(
      data['id'],
      data['name'],
      data['description'],
      data['price'],
      tags
    )
    $PokemonGlobal.accessories_data[hat.id] = hat
  end
end


def update_global_hairstyles_list()
  file_path = Settings::HAIRSTYLE_DATA_PATH
  json_data = File.read(file_path)
  hair_data = HTTPLite::JSON.parse(json_data)

  $PokemonGlobal.hairstyles_data = {}

  # Iterate through the JSON data and create Hat objects
  hair_data.each do |data|
    tags = data['tags'] ? data['tags'].split(',').map(&:strip) : []
    hair = Hairstyle.new(
      data['id'],
      data['name'],
      data['description'],
      data['price'],
      tags
    )
    $PokemonGlobal.hairstyles_data[hair.id] = hair
  end
end

def update_global_clothes_list()
  file_path = Settings::CLOTHES_DATA_PATH
  json_data = File.read(file_path)
  outfits_data = HTTPLite::JSON.parse(json_data)

  $PokemonGlobal.clothes_data = {}

  # Iterate through the JSON data and create Hat objects
  outfits_data.each do |data|
    tags = data['tags'] ? data['tags'].split(',').map(&:strip) : []
    outfit = Clothes.new(
      data['id'],
      data['name'],
      data['description'],
      data['price'],
      tags
    )
    $PokemonGlobal.clothes_data[outfit.id] = outfit
  end
end

def update_global_outfit_lists()
  update_global_hats_list
  update_global_hairstyles_list
  update_global_clothes_list
  update_global_accessories_list
end

