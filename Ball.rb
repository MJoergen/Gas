class Ball

  attr_reader :x, :y, :dir, :radius, :id, :mass, :vel_x, :vel_y, :color

  def initialize(window, x, y, dir, vel, rad, color, sound)
    @window, @x, @y, @dir, @radius, @mass, @color, @sound = window, x, y, dir, rad, 3.14*rad*rad, color, sound

    ## Initial values.
    @vel_x = Gosu::offset_x(@dir, vel)
    @vel_y = Gosu::offset_y(@dir, vel)

    @colliding = false
    @collision_point = false
  end

  def update
    @colliding = false
    @collision_point = false

    ### Move the ball
    @x = @x + @vel_x
    @y = @y + @vel_y

    ### Check collision with walls
    if @x+@radius > @window.univ_right  and @vel_x > 0
      @vel_x = -@vel_x
    end

    if @x-@radius < @window.univ_left   and @vel_x < 0
      @vel_x = -@vel_x
    end

    if @y+@radius > @window.univ_top    and @vel_y > 0
      @vel_y = -@vel_y
    end

    if @y-@radius < @window.univ_bottom and @vel_y < 0
      @vel_y = -@vel_y
    end
  end

  def draw
    color = @color  # Red
    if @colliding == true
      color = @color | 0x00808080
    end
    @window.circle_img.draw_rot(@x, @y, 0, @dir, 0.5, 0.5, @radius/50.0, @radius/50.0, color)

    if @collision_point == true
      @window.circle_img.draw_rot(@collisionPointX, @collisionPointY, 1, @dir,
				  0.5, 0.5, 7.0/50.0, 7.0/50.0, color ^ 0x00FFFFFF)
    end
  end

  def checkCollision(inst)  ### This method is only called once for each pair of balls
    if @x + @radius + inst.radius > inst.x and
      @x < inst.x + @radius + inst.radius and
      @y + @radius + inst.radius > inst.y and
      @y < inst.y + @radius + inst.radius      ## This big 'if' is an optimization.

      dist = Gosu::distance(inst.x, inst.y, @x, @y)
      if dist < (@radius + inst.radius)

	@collisionPointX = ((@x * inst.radius) + (inst.x * @radius))/(@radius + inst.radius)
	@collisionPointY = ((@y * inst.radius) + (inst.y * @radius))/(@radius + inst.radius)

	@collision_point = true

	new_vel_self = new_velocity(@mass, inst.mass, Vector[@vel_x, @vel_y], Vector[inst.vel_x, inst.vel_y],
				    Vector[@x, @y], Vector[inst.x, inst.y])
	new_vel_inst = new_velocity(inst.mass, @mass, Vector[inst.vel_x, inst.vel_y], Vector[@vel_x, @vel_y],
				    Vector[inst.x, inst.y], Vector[@x, @y])

	self.collision_ball(new_vel_self)
	inst.collision_ball(new_vel_inst)

      end
    end
  end

  def collision_ball(new_vel)
    @colliding = true

    delta_x = @vel_x - new_vel[0]
    delta_y = @vel_y - new_vel[1]

    if @sound == true
      delta_v = Math.sqrt(delta_x**2 + delta_y**2)
      volume = delta_v / 7.0
      @window.hit_sound.play(volume)
    end

    @vel_x = new_vel[0]
    @vel_y = new_vel[1]
  end

  ## This values the new velocity after the collision
  ## m1, v1, c1 : Mass, velocity, and center for this object.
  ## m2, v2, c2 : Mass, velocity, and center for the other object.
  ## The calculations are taken from the last equation of
  ## The velocity and centers must be Vector's.
  ## https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional_collision_with_two_moving_objects
  def new_velocity(m1, m2, v1, v2, c1, c2)
    f = (2*m2)/(m1+m2)  ## Number

    dv = v1 - v2  ### Vector
    dc = c1 - c2  ### Vector

    v_new = v1 - f * (dv.inner_product(dc))/(dc.inner_product(dc)) * dc  ### Vector

    ## If the two objects are already moving away from each, then don't change the velocity.
    if dv.inner_product(dc) > 0
      return v1     ### Vector
    else
      return v_new  ### Vector
    end
  end

end
