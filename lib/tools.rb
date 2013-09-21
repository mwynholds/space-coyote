module Tools
  def clockwise
    %w(n e s w)
  end

  def counterclockwise
    %w(n w s e)
  end

  def rights(direction)
    moves = counterclockwise
    moves.rotate(moves.index(direction) - 1)
  end

  def lefts(direction)
    moves = clockwise
    moves.rotate(moves.index(direction) - 1)
  end

  def move_right(direction)
    first_possible_move rights(direction)
  end

  def face_right(direction)
    moves = clockwise
    moves[ (moves.index(direction) + 1) % moves.length ]
  end

  def move_left(direction)
    first_possible_move lefts(direction)
  end

  def face_left(direction)
    moves = counterclockwise
    moves[ (moves.index(direction) + 1) % moves.length ]
  end

  def left_hand_rule(bearing)
    dir = @state.last_move || bearing
    dir = face_right(bearing) if dir == bearing
    move = move_left dir
    #puts "dir #{dir}, pos [#{me.x},#{me.y}], moves #{lefts(dir)} = #{move}"
    move
  end

  def pledge_algorithm
    bearing = closest_edge
    #print "pledge: bearing #{bearing}, edge #{at_edge?}, "
    if at_edge?
      @state.at_edge
      return left_hand_rule bearing
    end
    return move! bearing if can_move? bearing
    left_hand_rule bearing
  end

  def at_edge?
    return true if @state.at_edge?
    w, h = board.width, board.height
    return true if me.x == 0 || me.x == w - 1
    return true if me.y == 0 || me.y == h - 1
    false
  end

  def closest_edge
    w, h = board.width, board.height
    distances = { n: h-me.y, s: me.y, e: w-me.x, w: me.x }
    distances.min { |a,b| a[1] <=> b[1] }[0].to_s
  end

end
