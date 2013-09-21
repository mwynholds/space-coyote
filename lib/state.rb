class State
  def initialize
    @history = []
    @username = nil
  end

  def likely_positions
    bots = {}
    @history.reverse.each do |battle|
      battle.robots.each do |robot|
        bots[robot.username] ||= robot
      end
    end
    bots
  end

  def update(me, battle)
    @history << TurnState.new(battle)
    @username = me.username
  end

  def save_turn(turn)
    @history.last.turn = turn
  end

  def save_fire(enemy, comp)
    @history.last.fire = FireState.new enemy, comp
  end

  def hunting
    current_history.hunting = true
    at_edge if previous_history && previous_history.edge
  end

  def hunting?
    current_history.hunting
  end

  def at_edge
    current_history.edge = true
  end

  def at_edge?
    current_history.edge
  end

  def calculate_comp(enemy)
    return 1.0 if @history.empty?

    do_comp = dont_comp = 0
    last = @history.first
    @history.each do |h|
      if last.fire && last.fire.enemy.username == enemy.username
        prev_enemy = last.robot(enemy.username)
        cur_enemy = h.robot(enemy.username)
        hit = prev_enemy.armor > cur_enemy.armor
        do_comp   += 1 if  hit &&  last.fire.comp
        do_comp   += 1 if !hit && !last.fire.comp
        dont_comp += 1 if  hit && !last.fire.comp
        dont_comp += 1 if !hit &&  last.fire.comp
      end
    end
    do_comp > dont_comp ? true : false
  end

  def imminent_attackers
    return [] unless just_got_hit?

    prev_possibles = previous_battle.robots.select { |r| r.can_fire_at? previous_me }.map(&:username)
    cur_possibles = previous_battle.robots.select { |r| r.can_fire_at? current_me }.map(&:username)
    names = cur_possibles & prev_possibles
    names.map { |n| current_robot n }
  end

  def just_got_hit?
    return nil if @history.length < 2
    prev = previous_me
    cur = current_me
    prev.armor > cur.armor
  end

  def current_history
    @history[-1]
  end

  def current_battle
    current_history.battle
  end

  def current_me
    current_battle.robots.detect { |r| r.username == @username }
  end

  def current_robot(username)
    current_battle.robots.detect { |r| r.username == username }
  end

  def previous_history
    @history[-2]
  end

  def previous_battle
    previous_history.battle
  end

  def previous_me
    previous_battle.robots.detect { |r| r.username == @username }
  end

  def last_move
    return nil if @history.length < 2
    last_move_turn = @history.reverse[1..-1].detect do |h|
      %w(n e s w).include? h.turn
    end
    last_move_turn ? last_move_turn.turn : nil
  end

  def turn_index
    @history.length
  end
end

class TurnState
  attr_accessor :battle, :turn, :fire, :hunting, :edge

  def initialize(battle)
    @battle = battle
    @hunting = false
  end

  def robot(username)
    @battle.robots.detect { |r| r.username == username }
  end
end

class FireState
  attr_accessor :enemy, :comp

  def initialize(enemy, comp)
    @enemy = enemy
    @comp = comp
  end
end
