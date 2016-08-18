class Ball
	
	attr_reader :x, :y, :dir, :radius, :id, :mass, :vel_x, :vel_y
	
	def initialize(window, x, y, dir, vel, rad, mass)
		
		@window, @x, @y, @dir, @radius, @mass = window, x, y, dir, rad, mass
		
		## Initial values.
		@vel_x = Gosu::offset_x(@dir, vel)
		@vel_y = Gosu::offset_y(@dir, vel)
		
		@colliding = false
		@collision_point = false
		
		@collisionPointX = @x
		@collisionPointY = @y
		
	end
	
	def update
		@colliding = false
		@collision_point = false

		### Move the ball
		@x = @x + @vel_x
		@y = @y + @vel_y
		
		### Check collision with walls
		if @x > ($universe_width-@radius) and @vel_x > 0
			@vel_x = -@vel_x
		end
		if @x < @radius and @vel_x < 0
			@vel_x = -@vel_x
		end
		
		if @y > ($universe_height-@radius) and @vel_y > 0
			@vel_y = -@vel_y
		end
		
		if @y < @radius and @vel_y < 0
			@vel_y = -@vel_y
		end
	end
	
	def draw
		if @colliding == false
			@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xffFF0000)
		else
			@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xff00FF00)
			if @collision_point == true
				@window.circle_img.draw_rot(@collisionPointX+$window_width/2-$camera_x, @collisionPointY+$window_height/2-$camera_y, 1, @dir, 0.5, 0.5, 1.0*(7.0/50.0), 1.0*(7.0/50.0), 0xff0000FF)
			end
		end
	end
	
	def checkCollision(inst)  ### This method is only called once for each pair of balls
		
		if @x + @radius + inst.radius > inst.x and
		   @x < inst.x + @radius + inst.radius and
		   @y + @radius + inst.radius > inst.y and
		   @y < inst.y + @radius + inst.radius
			
			dist = Gosu::distance(inst.x, inst.y, @x, @y)
			if dist < (@radius + inst.radius)
				
				@collisionPointX = ((@x * inst.radius) + (inst.x * @radius))/(@radius + inst.radius)
				@collisionPointY = ((@y * inst.radius) + (inst.y * @radius))/(@radius + inst.radius)
				
				@collision_point = true
				
				new_vel_self = new_velocity(@mass, inst.mass, Vector[@vel_x, @vel_y], Vector[inst.vel_x, inst.vel_y], Vector[@x, @y], Vector[inst.x, inst.y])
				new_vel_inst = new_velocity(inst.mass, @mass, Vector[inst.vel_x, inst.vel_y], Vector[@vel_x, @vel_y], Vector[inst.x, inst.y], Vector[@x, @y])
				
				
				self.collision_ball(new_vel_self)
				inst.collision_ball(new_vel_inst)
				
			end
		end
	end
	
	def collision_ball(new_vel)
		@colliding = true
		
		@vel_x = new_vel[0]
		@vel_y = new_vel[1]
	end
	
	def new_velocity(m1, m2, v1, v2, c1, c2)
		
		f = (2*m2)/(m1+m2)  ## Number
		
		dv = v1 - v2  ### Vector
		dc = c1 - c2  ### Vector
		
		v_new = v1 - f * (dv.inner_product(dc))/(dc.inner_product(dc)) * dc  ### Vector
		
		if dv.inner_product(dc) > 0
			return v1     ### Vector
		else
			return v_new  ### Vector
		end
		
	end
	
end
