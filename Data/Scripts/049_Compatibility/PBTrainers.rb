# Le seul but de cette classe est de pouvoir continuer à utiliser le format PBTrainers::TRAINER quand on call la méthode de combat de dresseur
# pour ne pas à avoir à modifier tous les événements

module PBTrainers
  def self.const_missing(name)
    name.to_sym
  end
end