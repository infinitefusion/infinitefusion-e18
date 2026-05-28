# Mart-heals guarantee (#14): when SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS is
# on, a randomized mart's stock is augmented with a Potion if no HP-restore
# item was rolled. Tests the pure helper -- the alias wraps the engine fn and
# is wired by the `unless defined?` guard in NuzlockeWorldRules.rb.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Mart heals: setting OFF -> stock unchanged") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS, false)
  stock = [:ULTRABALL, :REVIVE, :ESCAPEROPE]
  out = NuzlockeWorldRules.ensure_heal_in_stock(stock)
  t.assert_eq("setting off -> identical stock", stock, out)
end

NuzlockeTestHarness.suite("Mart heals: MODE off (master) -> stock unchanged even if sub-switch on") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS, true)
  stock = [:ULTRABALL]
  t.assert_eq("master off wins", stock, NuzlockeWorldRules.ensure_heal_in_stock(stock))
end

NuzlockeTestHarness.suite("Mart heals: no healing item in stock -> Potion prepended") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS, true)
  out = NuzlockeWorldRules.ensure_heal_in_stock([:ULTRABALL, :REVIVE, :ESCAPEROPE])
  t.assert("Potion was added", out.include?(:POTION))
  t.assert_eq("Potion is the first item (prepended)", :POTION, out.first)
  t.assert("the original items are preserved", ([:ULTRABALL, :REVIVE, :ESCAPEROPE] - out).empty?)
end

NuzlockeTestHarness.suite("Mart heals: stock already has a heal -> unchanged (no duplication)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS, true)
  stock = [:SUPERPOTION, :ULTRABALL]
  out = NuzlockeWorldRules.ensure_heal_in_stock(stock)
  t.assert_eq("existing heal -> stock unchanged", stock, out)
end

NuzlockeTestHarness.suite("Mart heals: defensive on non-array input (no crash)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS, true)
  out = NuzlockeWorldRules.ensure_heal_in_stock(nil)
  t.assert("nil input -> returns input unchanged (no raise)", out.nil?)
end

end # defined?(NuzlockeTestHarness)
