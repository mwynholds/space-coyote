Dir['./lib/*.rb'].each { |f| require f }

include Tools
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

  # when:
  # 1. enough turns have gone by such that we've seen all the enemies (30?)
  # 2. only one enemy left
  # 3. i have more armor than them
  # then:
  # - act_aggressively

  if my.armor >= 2
    enemy = choose_enemy
    comp = calculate_comp enemy
    turn = act_aggressively enemy, comp
    return turn
  end

  act_defensively
end

def act_aggressively(enemy, comp)
  return hunt unless enemy
  return rest if my.ammo == 0
  return move_towards! enemy if obscured? enemy
  return fire_at! enemy, comp if can_fire_at? enemy
  return aim_at! enemy unless aiming_at? enemy
  move_towards! enemy
end

def hunt
  @state.hunting
  return pledge_algorithm
end

def fire_at!(enemy, compensate = false)
  @state.save_fire enemy, compensate
  direction = robot.direction_to(enemy)
  skew = (direction - robot.rotation).round(2)
  #puts "firing: direction #{direction}, skew: #{skew}"
  distance = robot.distance_to(enemy)
  max_distance = Math.sqrt(board.height * board.height + board.width * board.width)
  compensation = ( 10 - ( (10 - 3) * (distance / max_distance) ) ).round
  compensation *= -1 if rand(0..1) == 0
  skew += compensation if compensate
  fire! skew
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
