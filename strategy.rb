Dir['./lib/*.rb'].each { |f| require f }

include Aggressive
include Defensive

@state = State.new
on_turn do
  @state.update me, battle
  turn = handle_turn
  @state.save_turn turn
  turn
end

def handle_turn
  attacker = imminent_attacker
  return dodge attacker if attacker

  if my.ammo >= 2
    enemy = choose_enemy
    comp = calculate_comp enemy
    turn = act_aggressively enemy, compensate: comp
    @state.save_fire enemy, comp if turn =~ /^f/
    return turn
  end

  act_defensively
end

def imminent_attacker
  attackers = @state.imminent_attackers
  return nil if attackers.empty?
  attackers.shuffle[0]
end

def choose_enemy
  opponents.first
end

def calculate_comp(enemy)
  @state.calculate_comp enemy
end

# other ideas
# 1. change hunt direction after 20 moves (based on board h/w)
