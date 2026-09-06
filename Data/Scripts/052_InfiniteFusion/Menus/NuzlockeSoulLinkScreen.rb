#===============================================================================
# Soul Link pause-menu screen. Plain message/command driven so it works on
# every platform the game runs on (PC, Wine, JoiPlay).
#===============================================================================
module NuzlockeSoulLinkScreen
  module_function

  def show
    if !NuzlockeSoulLink.active?
      pbMessage(_INTL("Soul Link is turned off in the Nuzlocke settings."))
      return
    end
    if !NuzlockeSoulLink::Relay.configured?
      pbMessage(_INTL("No Soul Link relay is configured for this build. See tools/soul_link_relay/README.md."))
      return
    end
    loop do
      break if !NuzlockeSoulLink.in_room? ? !menu_no_room : !menu_in_room
    end
  end

  # Returns false to leave the loop.
  def menu_no_room
    cmds = [_INTL("Create a room"), _INTL("Join a room"), _INTL("Back")]
    choice = pbMessage(_INTL("Soul Link: you are not in a room yet. One player creates a room and shares the code; the other joins with it."), cmds, cmds.length)
    case choice
    when 0
      code = NuzlockeSoulLink.create_room!
      if code
        pbMessage(_INTL("Room created! Your code is \\C[1]{1}\\C[0].
Share it with your Soul Link partner.", code))
      else
        pbMessage(_INTL("Couldn't reach the Soul Link relay. Check your connection and try again."))
      end
      return true
    when 1
      code = pbEnterText(_INTL("Room code?"), 0, 6, "")
      return true if !code || code.strip.empty?
      case NuzlockeSoulLink.join_room!(code)
      when :ok
        pbMessage(_INTL("Joined room \\C[1]{1}\\C[0]. Your Pokémon are now soul-linked with everyone in it.", code.strip.upcase))
        NuzlockeSoulLink.process_pending_events(true)
      when :invalid
        pbMessage(_INTL("That doesn't look like a room code (6 letters/numbers)."))
      else
        pbMessage(_INTL("Room not found, or the relay couldn't be reached."))
      end
      return true
    end
    return false
  end

  def menu_in_room
    st = NuzlockeSoulLink.state
    partners = NuzlockeSoulLink.partner_summaries
    header = _INTL("Room \\C[1]{1}\\C[0] · last sync {2}", st[:room], NuzlockeSoulLink.ago_text(st[:last_pull]))
    if partners.empty?
      header += "\n" + _INTL("No partner has joined yet.")
    else
      partners.each do |p|
        header += "\n" + _INTL("{1}: {2} alive, {3} dead ({4})", p[:name], p[:alive], p[:dead], NuzlockeSoulLink.ago_text(p[:updated]))
      end
    end
    cmds = [_INTL("Sync now"), _INTL("View links"), _INTL("Leave room"), _INTL("Back")]
    choice = pbMessage(header, cmds, cmds.length)
    case choice
    when 0
      if NuzlockeSoulLink.sync!(true)
        n = NuzlockeSoulLink.process_pending_events(true)
        pbMessage(_INTL("Synced.")) if n.nil? || n == 0
      else
        pbMessage(_INTL("Couldn't reach the Soul Link relay."))
      end
      return true
    when 1
      show_links
      return true
    when 2
      if pbConfirmMessage(_INTL("Leave room {1}? Your Pokémon stay as they are; links simply stop syncing.", st[:room]))
        NuzlockeSoulLink.leave_room!
        pbMessage(_INTL("Left the room."))
        return false
      end
      return true
    end
    return false
  end

  # One page per linked Pokemon, plus a mismatch summary.
  def show_links
    mons = NuzlockeSoulLink.owned_mons.reject { |pk, _l| pk.respond_to?(:egg?) && pk.egg? }
    lines = []
    mons.each do |pk, loc|
      areas = NuzlockeSoulLink.link_areas_for(pk)
      next if areas.empty?
      partner_bits = []
      NuzlockeSoulLink.state[:partners].each do |_k, ledger|
        next if !ledger.is_a?(Hash) || !ledger["areas"].is_a?(Hash)
        areas.each do |a|
          e = ledger["areas"][a]
          next if !e.is_a?(Hash)
          who = (ledger["name"] || "?").to_s
          label = e["status"] == NuzlockeSoulLink::STATUS_ALIVE ? "#{e["name"]} (#{e["location"]})" : e["status"]
          partner_bits.push("#{who}: #{label}")
        end
      end
      partner_bits.push(_INTL("no partner link yet")) if partner_bits.empty?
      lines.push(_INTL("{1} ({2}, {3}) · {4}
{5}", pk.name, (pk.speciesName rescue pk.species), loc, areas.join(", "), partner_bits.join("; ")))
    end
    if lines.empty?
      pbMessage(_INTL("None of your Pokémon are linked yet. New catches link to the area they were caught in."))
    else
      lines.each { |l| pbMessage(l) }
    end
    mism = NuzlockeSoulLink.box_mismatches
    if !mism.empty?
      msg = mism.first(4).map { |m| _INTL("{1}: yours {2} ({3}), {4}'s {5} ({6})", m[:area], m[:mine], m[:my_location], m[:partner_name], m[:theirs], m[:their_location]) }.join("\n")
      pbMessage(_INTL("Linked-box rule: these pairs are split between party and box.
{1}", msg))
    end
  end
end
