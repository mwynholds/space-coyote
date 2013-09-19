class State
  def initialize
    @history = []
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

  def update(battle)
    @history << TurnState.new(battle)
  end

  def save_turn(turn)
    @history.last.turn = turn
  end

  def save_fire(enemy, comp)
    @history.last.fire = FireState.new enemy, comp
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
end

class TurnState
  attr_accessor :battle, :turn, :fire

  def initialize(battle)
    @battle = battle
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
