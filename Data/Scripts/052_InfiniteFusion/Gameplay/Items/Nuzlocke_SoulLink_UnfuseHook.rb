#===============================================================================
# Soul Link: unfuse hook. Lives in Gameplay/Items because pbUnfuse is defined in
# "New Items effects.rb" in this folder, which loads AFTER Gameplay/*.rb.
# The fusion object stays as the body half; the head is a new object added to
# the party/box. Find it by identity diff and hand it the head's link areas.
#===============================================================================
class Object
  unless private_method_defined?(:nuzlocke_sl_orig_pbUnfuse) ||
         method_defined?(:nuzlocke_sl_orig_pbUnfuse)
    alias_method :nuzlocke_sl_orig_pbUnfuse, :pbUnfuse
    def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)
      before = NuzlockeSoulLink.owned_mons.map(&:first)
      result = nuzlocke_sl_orig_pbUnfuse(pokemon, scene, supersplicers, pcPosition)
      if result && NuzlockeSoulLink.active?
        new_head = NuzlockeSoulLink.owned_mons.map(&:first).find { |m| !before.any? { |b| b.equal?(m) } }
        NuzlockeSoulLink.split_on_unfuse(pokemon, new_head)
      end
      return result
    end
  end
end
