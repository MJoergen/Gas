require 'gosu'
require 'matrix'

class GameWindow < Gosu::Window
	
	WIDTH = 860
	HEIGHT = 540
	TITLE = "Just another ruby project"
	
	attr_reader :circle_img
	
	def initialize
		
		super(WIDTH, HEIGHT, false)
		self.caption = TITLE
		
		## The size of the window
		$window_width = WIDTH*1.0
		$window_height = HEIGHT*1.0
		
		## The size of the "universe"
		$universe_width = $window_width - 60.0
		$universe_height = $window_height - 140.0
		
		## Only two images are used in this program
		@point_img = Gosu::Image.new(self, "media/Point2.png", true)
		@circle_img = Gosu::Image.new(self, "media/filled_circle.png", true)
		
		## Default font
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		
		## Camera coordinates
		$camera_x = $universe_width/2
		$camera_y = $universe_height/2
		
		## Game is paused by default. Unpause by pressing W
		@update_balls = false

		## Creates the objects
		self.restart
		
		## Kinetic Energy
		@kinetic_energy = 0.0
		@kin_big = 0.0
		@kin_small = 0.0
		@kin_dif_array = []
		
	end
	
	def restart  #### When you press Z, this method gets called
		
		$balls = []     ### Array containing every ball object.
		@ball_ids = []  ### Array used to manage the ball ids. Each ball has a unique number in "@id".
		
		for i in 0..39  ### Repeat 40 times
			## Create a ball
			self.create_ball(11.0+rand($universe_width-11.0), 11.0+rand($universe_height-11.0), rand(360), rand(5), 11.0, 3.14*(11.0**2))
		end
		
	end
	
	def update
		
		@kin_big = 0.0
		@kin_small = 0.0
		
		self.caption = "Elastic Collision  -  [FPS: #{Gosu::fps.to_s}]"
		
		if @update_balls == true
			
			## Update balls
			$balls.each     { |inst|  inst.update }
			## CHECK FOR BALL COLLISION. THIS IS DONE BY THE WINDOW, NOT BY EACH BALL. THE REASON IS OPTIMISATION.
			self.check_ball_collision
		
		end
		
		## Kinetic Energy. Currently not used.
		for i in 0..$balls.length-1
			
			if $balls[i].mass > 500.0
				@kin_big += $balls[i].get_kin
			else
				@kin_small += $balls[i].get_kin
			end
			
			# @kinetic_energy += $balls[i].get_kin
		end
		
		# puts "@kin_big : #{@kin_big} ... @kin_small : #{@kin_small}"
		# puts @kin_big - @kin_small
		
		@kin_dif_array << (@kin_big - @kin_small)
		
		if @kin_dif_array.length > 500
			@kin_dif_array.shift
		end
		
		# puts @kinetic_energy
		
		
		### MOVE THE CAMERA
		if button_down? Gosu::KbLeft
			$camera_x += -4
		end
		if button_down? Gosu::KbRight
			$camera_x += 4
		end
		if button_down? Gosu::KbUp
			$camera_y += -4
		end
		if button_down? Gosu::KbDown
			$camera_y += 4
		end
		
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbZ
				self.restart
			when Gosu::KbQ       ### When the game is paused, you can manually run each "step" of the simulation by pressing Q.
				$balls.each     { |inst|  inst.update }
				self.check_ball_collision
			when Gosu::KbW
				@update_balls = !@update_balls
		end
	end
	
	def draw
		
		## Draw the balls
		$balls.each     { |inst|  inst.draw }
		
		## Display the amount of balls
		@font.draw("Balls : #{$balls.length}", 10, 10, 1, 1.0, 1.0, 0xffffffff)
		
		
		### Kinetic Energy
		# draw_line(0, 300, 0xaaffffff, WIDTH, 300, 0xaaffffff, 0)
		
		# for i in 0..@kin_dif_array.length-1
			
			# y_offset = @kin_dif_array[i]/1000.0
			
			# @point_img.draw_rot(50 + i, 300 + y_offset*4, 1, 0, 0.5, 0.5, 0.5, 0.5, 0xffffff00)
			
		# end
		
		### Draw the universe borders
		draw_line(0+$window_width/2-$camera_x, 0+$window_height/2-$camera_y, 0xffffffff, $universe_width+$window_width/2-$camera_x, 0+$window_height/2-$camera_y, 0xffffffff, 0)
		draw_line(0+$window_width/2-$camera_x, $universe_height+$window_height/2-$camera_y, 0xffffffff, $universe_width+$window_width/2-$camera_x, $universe_height+$window_height/2-$camera_y, 0xffffffff, 0)
		
		draw_line(0+$window_width/2-$camera_x, 0+$window_height/2-$camera_y, 0xffffffff, 0+$window_width/2-$camera_x, $universe_height+$window_height/2-$camera_y, 0xffffffff, 0)
		draw_line($universe_width+$window_width/2-$camera_x, 0+$window_height/2-$camera_y, 0xffffffff, $universe_width+$window_width/2-$camera_x, $universe_height+$window_height/2-$camera_y, 0xffffffff, 0)
		
		### Draw the instructions
		@font.draw("Press W to Unpause/Pause", $window_width/2-50, 10, 2)
		@font.draw("Press Arrow Keys to Move camera", $window_width/2-50, 30, 2)
		
	end
	
	def create_ball(x, y, dir, vel, rad, mass)
		
		### Maximum of 200 balls when giving them a unique id. 200 is an abitrary number... change it to whatever you like. 
		for i in 0..199
			if !@ball_ids.include? i
				id = i
				@ball_ids << id
				inst = Ball.new(self, x, y, dir, vel, rad, id, mass) ### Create the ball
				$balls << inst  ### And remember the ball in the $balls array
				break
			end
		end
	end
	
	def check_ball_collision  
		
		### This method has been optimised to only check each collision ONCE. Therefore the entire collision check is 2x faster.
		### Thats also the reason why the method is run by the window, not by each ball.
		
		second_index = 1
		
		for i in 0..$balls.length-2  ## Ignore the last ball, since we have all the collisions checked by then
			
			for q in second_index..$balls.length-1  ### Check every ball from second_index
				$balls[i].checkCollision($balls[q])
			end
			
			second_index += 1
			
		end
		
	end
	
	def needs_cursor?
		true
	end
	
	def warp_camera(x, y)
		$camera_x = x
		$camera_y = y
	end
	
end

class Ball
	
	attr_reader :x, :y, :dir, :radius, :id, :mass, :vel_x, :vel_y
	
	def initialize(window, x, y, dir, vel, rad, id, mass)
		
		@window, @x, @y, @dir, @radius, @id, @mass = window, x, y, dir, rad, id, mass
		
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
		self.move
		
		### Follow ball number 0. The White ball.
		# if @id == 0
			# @window.warp_camera(@x, @y)
		# end
		
	end
	
	def draw
		if @id == 0
			@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xffFFFFFF)
		else
		
			if @colliding == false
				@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xffFF0000)
			else
				@window.circle_img.draw_rot(@x+$window_width/2-$camera_x, @y+$window_height/2-$camera_y, 0, @dir, 0.5, 0.5, 1.0*(@radius/50.0), 1.0*(@radius/50.0), 0xff00FF00)
				if @collision_point == true
					@window.circle_img.draw_rot(@collisionPointX+$window_width/2-$camera_x, @collisionPointY+$window_height/2-$camera_y, 1, @dir, 0.5, 0.5, 1.0*(7.0/50.0), 1.0*(7.0/50.0), 0xff0000FF)
				end
			end
		
		end
	end
	
	def move
		
		
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
		
		# @x = @x + @vel_x
		# @y = @y + @vel_y
		
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
	
	def get_kin
		return (@mass * (@vel_x**2+@vel_y**2))
	end
	
end

# show the window
window = GameWindow.new
window.show