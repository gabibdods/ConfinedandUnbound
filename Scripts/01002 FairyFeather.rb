# all this code does is add the fairy feather
# yeah

# Fairy Feather
Battle::Effects::Item::BasePowerMultiplier.register(:fairy_feather) { |_, _, move| move.type_fairy? }
