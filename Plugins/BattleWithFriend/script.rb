#===============================================================================
# Plugin: BattleWithFriend
# Version: v1.0
# Creator: ChatGPT - Champi
# Description: This plugin allows you to battle another player via a code.
#===============================================================================


def pbBattleFriend
  # Création du menu avec trois options
  commands = ["Send Code", "Battle Friend", "Leave"]
  command = pbShowCommands(nil, commands, -1)
  
  case command
  when 0
    send_code_to_friend
  when 1
    start_battle_with_friend
  when 2
    pbMessage("You canceled.")
  end
end

def send_code_to_friend
  pbMessage("Sending code to your friend...")

  trainer = $player   # Récupère le joueur actuel
  trainer_name = trainer.name   # Nom du dresseur
  trainer_sprite = GameData::TrainerType.get(trainer.trainer_type).id.to_s  # Nom interne du sprite du dresseur

  # Ouvre/crée le fichier .txt pour écrire les infos
  # Informations du dresseur
  data = "[#{trainer_sprite},#{trainer_name}]\n"

  # Informations sur chaque Pokémon de l'équipe
  trainer.party.each_with_index do |pokemon, index|
    species_data = GameData::Species.get(pokemon.species)  # Récupère les données de l'espèce
    data += "Pokemon = #{species_data.id.to_s.upcase},#{pokemon.level}\n"
    
    # Surnom du Pokémon (optionnel)
    if pokemon.name && pokemon.name != species_data.name
      data += "\tName = #{pokemon.name}\n"
    end

    # N'écrit la ligne Item que si un item est présent
    if pokemon.item
      data += "\tItem = #{GameData::Item.get(pokemon.item).id.to_s.upcase}\n"
    end

    data += "\tShiny = #{pokemon.shiny? ? 'True' : 'False'}\n"
    data += "\tSuperShiny = #{pokemon.super_shiny? ? 'True' : 'False'}\n"
    data += "\tTeraType = #{pokemon.tera_type ? GameData::Type.get(pokemon.tera_type).id.to_s.upcase : 'NONE'}\n"
    data += "\tNature = #{GameData::Nature.get(pokemon.nature).id.to_s.upcase}\n"  # Nature en anglais
    data += "\tAbility = #{pokemon.ability ? GameData::Ability.get(pokemon.ability).id.to_s.upcase : 'NONE'}\n"
    
    # IVs et EVs en une seule ligne
    data += "\tIV = #{pokemon.iv[:HP]},#{pokemon.iv[:ATTACK]},#{pokemon.iv[:DEFENSE]},#{pokemon.iv[:SPECIAL_ATTACK]},#{pokemon.iv[:SPECIAL_DEFENSE]},#{pokemon.iv[:SPEED]}\n"
    data += "\tEV = #{pokemon.ev[:HP]},#{pokemon.ev[:ATTACK]},#{pokemon.ev[:DEFENSE]},#{pokemon.ev[:SPECIAL_ATTACK]},#{pokemon.ev[:SPECIAL_DEFENSE]},#{pokemon.ev[:SPEED]}\n"

    # Moveset en une ligne
    move_ids = pokemon.moves.map { |move| GameData::Move.get(move.id).id.to_s.upcase }
    data += "\tMoveset = #{move_ids.join(',')}\n"
  end
  encrypt_and_save_data(data)
  #-pbMessage("Les informations du combat ont été sauvegardées dans 'battle_info.txt'.")
end

#-------------------------------------------------------------------------------------------
#Check file
def check_battle_with_friend
  file_path = "EncryptedBattleData\\Battle_Info.txt"
  
  # Vérifie si le fichier existe
  return File.exist?(file_path)
end


#-------------------------------------------------------------------------------------------
def start_battle_with_friend
  # Déchiffre et récupère les données du fichier
  decrypted_data = decrypt_data_from_file
  return pbMessage("Battle file not found.") unless decrypted_data

  # Vérification si `decrypted_data` est bien une chaîne de caractères
  unless decrypted_data.is_a?(String)
    return pbMessage("Invalid battle data.")
  end

  trainer_name = ""
  trainer_sprite = ""
  pokemon_team = []
  current_pokemon = nil

  # Lis les données déchiffrées comme avant
  decrypted_data.each_line do |line|
    line.strip!
    if line.start_with?("[")
      trainer_sprite, trainer_name = line.scan(/\[(.*?),(.*?)\]/).flatten
      puts "Trainer: #{trainer_name}, Sprite: #{trainer_sprite}"  # Debug
    elsif line.start_with?("Pokemon")
      species, level = line.match(/Pokemon = (\w+),(\d+)/).captures
      current_pokemon = { species: species.to_sym, level: level.to_i }
      pokemon_team << current_pokemon
      puts "Pokemon: #{species}, Level: #{level}"  # Debug
    elsif current_pokemon
      if line.start_with?("Name")
        current_pokemon[:name] = line.match(/Name = (.*)/).captures[0]
      elsif line.start_with?("Item")
        current_pokemon[:item] = line.match(/Item = (\w+)/).captures[0].to_sym
      elsif line.start_with?("Shiny")
        current_pokemon[:shiny] = (line.match(/Shiny = (True|False)/).captures[0] == "True")
      elsif line.start_with?("SuperShiny")
        current_pokemon[:super_shiny] = (line.match(/SuperShiny = (True|False)/).captures[0] == "True")
      elsif line.start_with?("TeraType") # Teratype
        current_pokemon[:tera_type] = line.match(/TeraType = (\w+)/).captures[0].to_sym
      elsif line.start_with?("Nature")
        current_pokemon[:nature] = line.match(/Nature = (\w+)/).captures[0].to_sym
      elsif line.start_with?("Ability")
        current_pokemon[:ability] = line.match(/Ability = (\w+)/).captures[0].to_sym
      elsif line.start_with?("IV")
        current_pokemon[:iv] = line.match(/IV = ([\d,]+)/).captures[0].split(",").map(&:to_i)
      elsif line.start_with?("EV")
        current_pokemon[:ev] = line.match(/EV = ([\d,]+)/).captures[0].split(",").map(&:to_i)
      elsif line.start_with?("Moveset")
        current_pokemon[:moveset] = line.match(/Moveset = ([\w,]+)/).captures[0].split(",").map(&:to_sym)
      end
    end
  end

  # Créer l'équipe de Pokémon pour le dresseur
  party = pokemon_team.map do |pkmn_data|
    pokemon = Pokemon.new(pkmn_data[:species], pkmn_data[:level])
    pokemon.item = pkmn_data[:item] ? GameData::Item.get(pkmn_data[:item]).id : nil
    pokemon.shiny = pkmn_data[:shiny] unless pkmn_data[:shiny].nil?
    pokemon.super_shiny = pkmn_data[:super_shiny] unless pkmn_data[:super_shiny].nil?
    pokemon.tera_type = pkmn_data[:tera_type] ? GameData::Type.get(pkmn_data[:tera_type]).id : nil
    pokemon.nature = GameData::Nature.get(pkmn_data[:nature]).id if pkmn_data[:nature]
    pokemon.ability = GameData::Ability.get(pkmn_data[:ability]).id if pkmn_data[:ability]
    pokemon.iv = pkmn_data[:iv] if pkmn_data[:iv]
    pokemon.ev = pkmn_data[:ev] if pkmn_data[:ev]
    pokemon.name = pkmn_data[:name] if pkmn_data[:name]
    if pkmn_data[:moveset]
      pkmn_data[:moveset].each_with_index do |move, index|
        pokemon.moves[index] = Pokemon::Move.new(GameData::Move.get(move).id)
      end
    end
    pokemon
  end

  # Créer le dresseur et lancer le combat
  trainer = NPCTrainer.new(trainer_name, GameData::TrainerType.get(trainer_sprite.to_sym).id)
  trainer.party = party
  TrainerBattle.start(trainer)
end


def encrypt_and_save_data(decrypted_data)
  Dir.mkdir("EncryptedBattleData") unless File.exists?("EncryptedBattleData")
  file_path = "EncryptedBattleData\\Battle_Info.txt"
  
  begin
    File.open(file_path, "w") do |file|
      puts "Données à chiffrer : #{decrypted_data}"  # Debug : Affiche les données à chiffrer
      encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(decrypted_data))].pack("m")
      file.puts "(\"#{encrypted_data}\")"
      # pbMessage("Les données de combat ont été chiffrées et sauvegardées.")
    end
  rescue StandardError => e
    pbMessage("Error while saving the data: #{e.message}")
  end
end

def decrypt_data_from_file
  rootFolder = File.dirname(__FILE__)
  filePath = Dir.glob(File.join(rootFolder, "**", "Battle_Info.txt")).first

  if filePath.nil?
    puts "Battle info file not found"
    return false
  end

  begin
    encrypted_data = File.read(filePath)
    decrypted_data = Marshal.restore(Zlib::Inflate.inflate(encrypted_data.unpack("m")[0]))
    puts "Decryption successful: #{decrypted_data}"  # Debug
    return decrypted_data
  rescue StandardError => e
    pbMessage(_INTL("Error while decrypting the data: {1}", e.message))
    return nil
  end
end



