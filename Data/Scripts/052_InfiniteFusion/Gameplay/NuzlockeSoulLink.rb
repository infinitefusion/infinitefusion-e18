#===============================================================================
# Nuzlocke Soul Link (Soullocke) -- zero-provider relay version
#
# Two (or more) players each run their own Nuzlocke. Catches from the same AREA
# are soul-linked across players:
#   * if a partner's Pokemon from an area dies, your Pokemon linked to that area
#     dies too (linked death);
#   * if a partner never caught their first encounter in an area, your catch
#     from that area is released (broken link);
#   * a fusion carries the link areas of BOTH halves; a linked death of either
#     half kills the whole fusion (Soullocke deaths are absolute).
#
# Transport: a tiny HTTP relay (tools/soul_link_relay/worker.js, a Cloudflare
# Worker + KV). Players never log in anywhere -- one player creates a ROOM CODE
# in-game, the other types it in. Each game POSTs its own ledger (one JSON blob
# per player) and GETs everyone else's. No player can write another's blob.
#
# Trust model: honor system. The game applies what the partner's ledger says,
# after a confirmation prompt. Nothing here is a cheat-proof server.
#
# Everything is gated on SWITCH_NUZLOCKE_MODE + SWITCH_NUZLOCKE_SOUL_LINK.
#===============================================================================

class Pokemon
  attr_accessor :nuzlocke_link_areas        # Array<String>: areas this mon is linked through
  attr_accessor :nuzlocke_link_areas_head   # Array<String>: the subset belonging to the head half (fusions)
end

class PokemonGlobalMetadata
  attr_accessor :nuzlocke_soul_link         # Hash: room/state, see NuzlockeSoulLink.state
end

module NuzlockeSoulLink
  module_function

  DEFAULT_RELAY_URL = "https://REPLACE-ME.workers.dev"   # see tools/soul_link_relay/README.md
  RELAY_URL_FILE    = "soul_link_relay.txt"               # optional override next to the .exe
  LEDGER_VERSION    = 1
  PULL_INTERVAL     = 30      # seconds between automatic pulls
  PUSH_INTERVAL     = 300     # seconds between automatic (non-dirty) pushes
  FAIL_BACKOFF      = 120     # seconds to stay quiet after a relay failure
  CODE_PATTERN      = /\A[A-Z2-9]{6}\z/
  PLAYER_PATTERN    = /\A[A-Za-z0-9_\-]{1,40}\z/

  STATUS_ALIVE  = "alive"
  STATUS_DEAD   = "dead"
  STATUS_FAILED = "failed"

  #-----------------------------------------------------------------------------
  # Gating / state
  #-----------------------------------------------------------------------------
  def active?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return $game_switches[SWITCH_NUZLOCKE_SOUL_LINK] ? true : false
  end

  # Persistent per-save state (lives on $PokemonGlobal so it saves with the game).
  def state
    return {} if !$PokemonGlobal
    $PokemonGlobal.nuzlocke_soul_link ||= {}
    st = $PokemonGlobal.nuzlocke_soul_link
    st[:partners]     ||= {}
    st[:dead_areas]   ||= []
    st[:failed_areas] ||= []
    st[:applied]      ||= {}
    st[:pending]      ||= []
    return st
  end

  def room;        state[:room]; end
  def in_room?;    r = room; r.is_a?(String) && !r.empty?; end
  def dirty!;      state[:dirty] = true; end

  def now; Time.now.to_i; end

  # Stable, URL-safe identity for this save: trainer name + a slice of the ID.
  def player_key
    st = state
    return st[:player_key] if st[:player_key].is_a?(String) && !st[:player_key].empty?
    name = ($Trainer && $Trainer.respond_to?(:name) && $Trainer.name) ? $Trainer.name.to_s : "Player"
    id   = ($Trainer && $Trainer.respond_to?(:id) && $Trainer.id.is_a?(Integer)) ? ($Trainer.id % 100000) : rand(100000)
    key  = "#{name}_#{id}".gsub(/[^A-Za-z0-9_\-]/, "")
    key  = "Player_#{id}" if key.empty? || key !~ PLAYER_PATTERN
    st[:player_key] = key[0, 40]
    return st[:player_key]
  end

  # Settings that must survive Reset Run's snapshot reload (room membership is
  # a pairing, not run progress; everything else is wiped).
  def export_config
    st = state
    return { room: st[:room], player_key: st[:player_key] }
  end

  def import_config(cfg)
    return if !cfg.is_a?(Hash) || !$PokemonGlobal
    $PokemonGlobal.nuzlocke_soul_link = {}
    st = state
    st[:room] = cfg[:room]
    st[:player_key] = cfg[:player_key]
    dirty!
  end

  #-----------------------------------------------------------------------------
  # Link areas on Pokemon
  #-----------------------------------------------------------------------------
  # Areas a mon is linked through: explicit tags first; otherwise fall back to
  # the map the mon was obtained on (lets a run enable Soul Link mid-way).
  def link_areas_for(pkmn)
    return [] if !pkmn
    areas = pkmn.nuzlocke_link_areas
    return areas.compact.uniq if areas.is_a?(Array) && !areas.empty?
    map_id = (pkmn.respond_to?(:obtain_map) ? pkmn.obtain_map : nil)
    if map_id.is_a?(Integer) && map_id > 0 && defined?(pbGetMapNameFromId)
      name = (pbGetMapNameFromId(map_id) rescue nil)
      return [name] if name.is_a?(String) && !name.strip.empty?
    end
    return []
  end

  # Tag a newly obtained mon with the current area (catch, starter, gift, hatch).
  def tag_acquired(pkmn, area = nil)
    return if !active? || !pkmn
    return if pkmn.respond_to?(:egg?) && pkmn.egg?
    area ||= NuzlockeCaptureRules.current_area_key
    return if !area.is_a?(String) || area.empty?
    pkmn.nuzlocke_link_areas ||= []
    pkmn.nuzlocke_link_areas.push(area) if !pkmn.nuzlocke_link_areas.include?(area)
    dirty!
  end

  # Fusion: the body object becomes the fusion; it inherits the head's areas and
  # remembers which ones came from the head so an unfuse can hand them back.
  def merge_on_fuse(body, head)
    return if !body || !head
    body_areas = link_areas_for(body)
    head_areas = link_areas_for(head)
    body.nuzlocke_link_areas = (body_areas + head_areas).uniq
    body.nuzlocke_link_areas_head = head_areas
    dirty!
  end

  # Unfuse: +fusion+ stays as the body half, +new_head+ is the freshly created
  # head half. Give the head its own areas back.
  def split_on_unfuse(fusion, new_head)
    return if !fusion
    head_areas = fusion.nuzlocke_link_areas_head || []
    all_areas  = fusion.nuzlocke_link_areas || []
    fusion.nuzlocke_link_areas = all_areas - head_areas
    fusion.nuzlocke_link_areas_head = nil
    new_head.nuzlocke_link_areas = head_areas.dup if new_head
    dirty!
  end

  # Perma-death survivor (Head/Body modes): the survivor keeps only its own
  # half's areas; the dead half's areas are recorded as dead.
  def split_on_survivor(fused, survivor, keep_body)
    return if !fused || !survivor
    head_areas = fused.nuzlocke_link_areas_head || []
    all_areas  = link_areas_for(fused)
    if keep_body
      survivor.nuzlocke_link_areas = all_areas - head_areas
      dead = head_areas
    else
      survivor.nuzlocke_link_areas = head_areas.dup
      dead = all_areas - head_areas
    end
    survivor.nuzlocke_link_areas_head = nil
    note_dead_areas(dead)
  end

  #-----------------------------------------------------------------------------
  # Run events -> my ledger
  #-----------------------------------------------------------------------------
  def note_dead_areas(areas)
    return if !active? || !areas.is_a?(Array) || areas.empty?
    st = state
    areas.each { |a| st[:dead_areas].push(a) if a.is_a?(String) && !st[:dead_areas].include?(a) }
    dirty!
  end

  # A mon was fully removed by perma-death.
  def note_death(pkmn)
    note_dead_areas(link_areas_for(pkmn))
  end

  # Called at the end of every wild battle (from the capture-rules wrapper,
  # BEFORE the per-battle flags are cleared). In first-encounter mode, a first
  # encounter that ended without a catch is a forfeited area => "failed" link.
  def note_wild_battle_end
    return if !active?
    return if NuzlockeCaptureRules.catch_rule_mode != NuzlockeCaptureRules::CATCH_RULE_FIRST_ENCOUNTER
    area = NuzlockeCaptureRules.area_recorded_this_battle
    return if !area
    return if NuzlockeCaptureRules.caught_areas.include?(area)
    st = state
    st[:failed_areas].push(area) if !st[:failed_areas].include?(area)
    dirty!
  end

  # Everything the player owns, as [pokemon, location] pairs.
  def owned_mons
    out = []
    if $Trainer && $Trainer.party
      $Trainer.party.each { |pk| out.push([pk, "party"]) if pk }
    end
    if $PokemonStorage && $PokemonStorage.respond_to?(:boxes)
      ($PokemonStorage.boxes rescue []).each do |box|
        next if !box
        (box.pokemon rescue []).each { |pk| out.push([pk, "box"]) if pk }
      end
    end
    return out
  end

  # Build my ledger. alive (a living linked mon) wins over dead, dead over failed.
  def build_ledger
    areas = {}
    owned_mons.each do |pk, loc|
      next if pk.respond_to?(:egg?) && pk.egg?
      link_areas_for(pk).each do |a|
        next if areas[a] && areas[a]["status"] == STATUS_ALIVE
        areas[a] = {
          "species"  => (pk.species rescue "?").to_s,
          "name"     => (pk.name rescue "?").to_s,
          "status"   => STATUS_ALIVE,
          "location" => loc
        }
      end
    end
    st = state
    st[:dead_areas].each do |a|
      next if areas[a] && areas[a]["status"] == STATUS_ALIVE
      areas[a] = { "species" => "", "name" => "", "status" => STATUS_DEAD, "location" => "" }
    end
    st[:failed_areas].each do |a|
      next if areas[a]
      areas[a] = { "species" => "", "name" => "", "status" => STATUS_FAILED, "location" => "" }
    end
    return {
      "v"       => LEDGER_VERSION,
      "name"    => (($Trainer && $Trainer.respond_to?(:name) && $Trainer.name) ? $Trainer.name.to_s : "?"),
      "key"     => player_key,
      "updated" => now,
      "areas"   => areas
    }
  end

  #-----------------------------------------------------------------------------
  # Partner ledgers -> events
  #-----------------------------------------------------------------------------
  # Compare partner ledgers against my living linked mons. Returns new events:
  #   { partner_key:, partner_name:, area:, status:, species:, name: }
  # An event is only produced once per (partner, area, status) -- see :applied.
  def compute_events(partners = state[:partners])
    events = []
    return events if !partners.is_a?(Hash) || partners.empty?
    mine = owned_mons
    partners.each do |pkey, ledger|
      next if pkey == player_key
      areas = (ledger.is_a?(Hash) ? ledger["areas"] : nil)
      next if !areas.is_a?(Hash)
      areas.each do |area, entry|
        next if !entry.is_a?(Hash)
        status = entry["status"]
        next if status != STATUS_DEAD && status != STATUS_FAILED
        key = "#{pkey}|#{area}|#{status}"
        next if state[:applied][key]
        linked = mine.select { |pk, _loc| link_areas_for(pk).include?(area) }
        next if linked.empty?
        events.push({
          partner_key:  pkey,
          partner_name: (ledger["name"] || pkey).to_s,
          area:         area,
          status:       status,
          species:      entry["species"].to_s,
          name:         entry["name"].to_s
        })
      end
    end
    return events
  end

  # Linked-box mismatches (info only, never enforced): my linked mon is in the
  # party while the partner's from the same area is boxed, or vice versa.
  def box_mismatches(partners = state[:partners])
    out = []
    return out if !partners.is_a?(Hash) || partners.empty?
    mine = owned_mons
    partners.each do |pkey, ledger|
      next if pkey == player_key
      areas = (ledger.is_a?(Hash) ? ledger["areas"] : nil)
      next if !areas.is_a?(Hash)
      areas.each do |area, entry|
        next if !entry.is_a?(Hash) || entry["status"] != STATUS_ALIVE
        mine.each do |pk, loc|
          next if !link_areas_for(pk).include?(area)
          next if loc == entry["location"]
          out.push({ partner_name: (ledger["name"] || pkey).to_s, area: area,
                     mine: (pk.name rescue "?").to_s, my_location: loc,
                     theirs: entry["name"].to_s, their_location: entry["location"].to_s })
        end
      end
    end
    return out
  end

  # Remove a mon from the party or storage, return its item to the Bag, and
  # record its areas as dead. Returns true if it was found and removed.
  def release_mon(pkmn)
    return false if !pkmn
    found = false
    if $Trainer && $Trainer.party && $Trainer.party.any? { |m| m.equal?(pkmn) }
      $Trainer.party.delete_if { |m| m.equal?(pkmn) }
      found = true
    end
    if !found && $PokemonStorage && $PokemonStorage.respond_to?(:boxes)
      boxes = ($PokemonStorage.boxes rescue [])
      boxes.each_with_index do |box, b|
        next if !box
        list = (box.pokemon rescue [])
        list.each_with_index do |m, i|
          next if !m.equal?(pkmn)
          if $PokemonStorage.respond_to?(:[]=)
            $PokemonStorage[b, i] = nil
          else
            list[i] = nil
          end
          found = true
          break
        end
        break if found
      end
    end
    return false if !found
    NuzlockeBattleRules.reclaim_held_item(pkmn) if defined?(NuzlockeBattleRules)
    note_dead_areas(link_areas_for(pkmn))
    return true
  end

  # Apply one event: prompt, then release every living mon linked to the area.
  # Returns :applied, :deferred, or :nothing (no linked mon left).
  def apply_event(event, confirm = true)
    key = "#{event[:partner_key]}|#{event[:area]}|#{event[:status]}"
    linked = owned_mons.select { |pk, _l| link_areas_for(pk).include?(event[:area]) }.map(&:first)
    if linked.empty?
      state[:applied][key] = true
      return :nothing
    end
    names = linked.map { |pk| "#{pk.name} (#{pk.speciesName rescue pk.species})" }.join(", ")
    what = (event[:status] == STATUS_DEAD) ?
      _INTL("{1}'s {2} from {3} has died.", event[:partner_name], event[:name].empty? ? event[:species] : event[:name], event[:area]) :
      _INTL("{1} never caught their first encounter in {2}.", event[:partner_name], event[:area])
    if confirm
      ok = pbConfirmMessage(_INTL("Soul Link: {1}
Your linked {2} must be released. Release now?", what, names))
      return :deferred if !ok
    else
      pbMessage(_INTL("Soul Link: {1}
Your linked {2} must be released.", what, names))
    end
    linked.each { |pk| release_mon(pk) }
    pbMessage(_INTL("{1} can never battle again...", names))
    state[:applied][key] = true
    dirty!
    return :applied
  end

  # Process every outstanding event (called from a safe overworld context).
  def process_pending_events(confirm = true)
    return if !active? || !in_room?
    events = compute_events
    applied = 0
    events.each do |ev|
      applied += 1 if apply_event(ev, confirm) == :applied
    end
    push_if_needed(true) if applied > 0
    return applied
  end

  #-----------------------------------------------------------------------------
  # Relay transport (HTTP). Every call returns nil on failure and records a
  # backoff window so a dead relay never stalls the game more than once.
  #-----------------------------------------------------------------------------
  module Relay
    module_function

    def base_url
      override = nil
      begin
        override = File.read(NuzlockeSoulLink::RELAY_URL_FILE).strip if File.file?(NuzlockeSoulLink::RELAY_URL_FILE)
      rescue
        override = nil
      end
      url = (override && !override.empty?) ? override : NuzlockeSoulLink::DEFAULT_RELAY_URL
      return url.sub(/\/+\z/, "")
    end

    def configured?
      return !base_url.include?("REPLACE-ME")
    end

    def http_get(url)
      return nil if !defined?(HTTPLite)
      resp = HTTPLite.get(url)
      return nil if !resp.is_a?(Hash) || resp[:status] != 200
      return resp[:body]
    rescue
      return nil
    end

    def http_post(url, body)
      return nil if !defined?(HTTPLite)
      resp = HTTPLite.post_body(url, body, "application/json")
      return nil if !resp.is_a?(Hash) || (resp[:status] != 200 && resp[:status] != 204)
      return resp[:body] || ""
    rescue
      return nil
    end

    def parse(body)
      return nil if !body.is_a?(String) || body.empty?
      return HTTPLite::JSON.parse(body) if defined?(HTTPLite::JSON)
      return nil
    rescue
      return nil
    end

    def create_room
      body = http_post("#{base_url}/room", "{}")
      data = parse(body)
      code = data.is_a?(Hash) ? data["code"] : nil
      return (code.is_a?(String) && code =~ NuzlockeSoulLink::CODE_PATTERN) ? code : nil
    end

    def push(code, key, ledger)
      body = http_post("#{base_url}/room/#{code}/#{key}", serialize_json(ledger))
      return !body.nil?
    end

    def pull(code)
      data = parse(http_get("#{base_url}/room/#{code}"))
      return nil if !data.is_a?(Hash)
      players = data["players"]
      return players.is_a?(Hash) ? players : nil
    end

    def leave(code, key)
      return !http_post("#{base_url}/room/#{code}/#{key}/leave", "{}").nil?
    end
  end

  def relay_down?
    st = state
    return st[:fail_until].is_a?(Integer) && st[:fail_until] > now
  end

  def note_relay_failure
    state[:fail_until] = now + FAIL_BACKOFF
  end

  #-----------------------------------------------------------------------------
  # Sync entry points
  #-----------------------------------------------------------------------------
  def create_room!
    code = Relay.create_room
    if !code
      note_relay_failure
      return nil
    end
    st = state
    st[:room] = code
    st[:partners] = {}
    st[:applied] = {}
    dirty!
    push_if_needed(true)
    return code
  end

  def join_room!(code)
    code = code.to_s.strip.upcase
    return :invalid if code !~ CODE_PATTERN
    players = Relay.pull(code)
    if players.nil?
      note_relay_failure
      return :not_found
    end
    st = state
    st[:room] = code
    st[:partners] = players.reject { |k, _v| k == player_key }
    st[:applied] = {}
    st[:last_pull] = now
    dirty!
    push_if_needed(true)
    return :ok
  end

  def leave_room!
    st = state
    Relay.leave(st[:room], player_key) if in_room?
    st[:room] = nil
    st[:partners] = {}
    st[:applied] = {}
    st[:pending] = []
  end

  # Push my ledger when dirty (or forced, or stale). Returns true on success.
  def push_if_needed(force = false)
    return false if !active? || !in_room?
    st = state
    return false if relay_down? && !force
    stale = !st[:last_push].is_a?(Integer) || (now - st[:last_push]) > PUSH_INTERVAL
    return false if !force && !st[:dirty] && !stale
    ok = Relay.push(st[:room], player_key, build_ledger)
    if ok
      st[:dirty] = false
      st[:last_push] = now
    else
      note_relay_failure
    end
    return ok
  end

  # Pull partner ledgers when due. Returns true on success.
  def pull_if_needed(force = false)
    return false if !active? || !in_room?
    st = state
    return false if relay_down? && !force
    due = !st[:last_pull].is_a?(Integer) || (now - st[:last_pull]) > PULL_INTERVAL
    return false if !force && !due
    players = Relay.pull(st[:room])
    if players.nil?
      note_relay_failure
      return false
    end
    st[:partners] = players.reject { |k, _v| k == player_key }
    st[:last_pull] = now
    return true
  end

  def sync!(force = true)
    pushed = push_if_needed(force)
    pulled = pull_if_needed(force)
    return pushed || pulled
  end

  # Overworld cadence: on every map change, push if dirty, pull if due. Events
  # found are NOT applied here (map setup is not a safe place for prompts);
  # they are applied on the next step via the step hook below.
  def on_map_change
    return if !active? || !in_room?
    push_if_needed
    pull_if_needed
  rescue => e
    PBDebug.log("[SoulLink] on_map_change failed: #{e.message}") if defined?(PBDebug)
  end

  def on_step
    return if !active? || !in_room?
    return if compute_events.empty?
    process_pending_events(true)
  rescue => e
    PBDebug.log("[SoulLink] on_step failed: #{e.message}") if defined?(PBDebug)
  end

  def after_battle
    return if !active? || !in_room?
    push_if_needed
  rescue => e
    PBDebug.log("[SoulLink] after_battle failed: #{e.message}") if defined?(PBDebug)
  end

  # Human-readable partner summary for the screen.
  def partner_summaries
    st = state
    st[:partners].map do |k, ledger|
      name = (ledger.is_a?(Hash) && ledger["name"]) ? ledger["name"].to_s : k
      upd  = (ledger.is_a?(Hash) && ledger["updated"].is_a?(Integer)) ? ledger["updated"] : nil
      areas = (ledger.is_a?(Hash) && ledger["areas"].is_a?(Hash)) ? ledger["areas"] : {}
      alive = areas.count { |_a, e| e.is_a?(Hash) && e["status"] == STATUS_ALIVE }
      dead  = areas.count { |_a, e| e.is_a?(Hash) && e["status"] == STATUS_DEAD }
      { key: k, name: name, updated: upd, alive: alive, dead: dead }
    end
  end

  def ago_text(epoch)
    return _INTL("never") if !epoch.is_a?(Integer)
    d = now - epoch
    return _INTL("just now") if d < 60
    return _INTL("{1}m ago", d / 60) if d < 3600
    return _INTL("{1}h ago", d / 3600) if d < 86400
    return _INTL("{1}d ago", d / 86400)
  end
end

#===============================================================================
# Hooks
#===============================================================================
# Starter / gift / trade acquisitions funnel through pbNicknameAndStore.
class Object
  unless private_method_defined?(:nuzlocke_sl_orig_pbNicknameAndStore) ||
         method_defined?(:nuzlocke_sl_orig_pbNicknameAndStore)
    alias_method :nuzlocke_sl_orig_pbNicknameAndStore, :pbNicknameAndStore
    def pbNicknameAndStore(pkmn)
      NuzlockeSoulLink.tag_acquired(pkmn)
      return nuzlocke_sl_orig_pbNicknameAndStore(pkmn)
    end
  end

  unless private_method_defined?(:nuzlocke_sl_orig_pbAddPokemonSilent) ||
         method_defined?(:nuzlocke_sl_orig_pbAddPokemonSilent)
    alias_method :nuzlocke_sl_orig_pbAddPokemonSilent, :pbAddPokemonSilent
    def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
      NuzlockeSoulLink.tag_acquired(pkmn) if pkmn.is_a?(Pokemon)
      return nuzlocke_sl_orig_pbAddPokemonSilent(pkmn, level, see_form)
    end
  end

  # Egg hatch: the hatched mon links to where it hatched.
  unless private_method_defined?(:nuzlocke_sl_orig_pbHatch) ||
         method_defined?(:nuzlocke_sl_orig_pbHatch)
    alias_method :nuzlocke_sl_orig_pbHatch, :pbHatch
    def pbHatch(pokemon)
      result = nuzlocke_sl_orig_pbHatch(pokemon)
      NuzlockeSoulLink.tag_acquired(pokemon)
      return result
    end
  end

end

# Caught Pokemon: tag right before the engine stores it.
module PokeBattle_BattleCommon
  unless method_defined?(:nuzlocke_sl_orig_pbStorePokemon)
    alias_method :nuzlocke_sl_orig_pbStorePokemon, :pbStorePokemon
    def pbStorePokemon(pkmn)
      NuzlockeSoulLink.tag_acquired(pkmn)
      return nuzlocke_sl_orig_pbStorePokemon(pkmn)
    end
  end
end

# Fusion: pbFusionScreen turns @pokemon1 (body) into the fusion; merge the
# head's areas into it.
if defined?(PokemonFusionScene)
  class PokemonFusionScene
    unless method_defined?(:nuzlocke_sl_orig_pbFusionScreen)
      alias_method :nuzlocke_sl_orig_pbFusionScreen, :pbFusionScreen
      def pbFusionScreen(*args)
        result = nuzlocke_sl_orig_pbFusionScreen(*args)
        if NuzlockeSoulLink.active? && @pokemon1 && @pokemon2
          NuzlockeSoulLink.merge_on_fuse(@pokemon1, @pokemon2)
        end
        return result
      end
    end
  end
end

# Overworld cadence.
if defined?(Events)
  Events.onMapChange += proc { |_sender, _e| NuzlockeSoulLink.on_map_change }
  Events.onStepTakenTransferPossible += proc { |_sender, e|
    handled = e[0]
    next if handled[0]
    NuzlockeSoulLink.on_step
  }
  Events.onEndBattle += proc { |_sender, _e| NuzlockeSoulLink.after_battle }
end
