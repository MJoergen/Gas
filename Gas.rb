require 'gosu'
require 'matrix'
require_relative 'Ball'

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
		@point_img  = Gosu::Image.new(self, "media/Point2.png", true)
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
		
	end
	
	def restart  #### When you press Z, this method gets called
		
		$balls = []     ### Array containing every ball object.
		
		for i in 0..39  ### Repeat 40 times
      $balls << Ball.new(self, 11.0+rand($universe_width-11.0), 11.0+rand($universe_height-11.0),
        rand(360), rand(5.0), 11.0, 3.14*(11.0**2)) ### Create the ball
		end
		
	end
	
	def update
		self.caption = "Gas  -  [FPS: #{Gosu::fps.to_s}]"
		
		if @update_balls == true
			## Update balls
			$balls.each     { |inst|  inst.update }
			## CHECK FOR BALL COLLISION. THIS IS DONE BY THE WINDOW, NOT BY EACH BALL. THE REASON IS OPTIMISATION.
			self.check_ball_collision
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
		
		### Draw the universe borders
		draw_line(30, 70, 0xffffffff, 30+$universe_width, 70, 0xffffffff, 0)
		draw_line(30, 70+$universe_height, 0xffffffff, 30+$universe_width, 70+$universe_height, 0xffffffff, 0)
		
		draw_line(30, 70, 0xffffffff, 30, 70+$universe_height, 0xffffffff, 0)
		draw_line(30+$universe_width, 70, 0xffffffff, 30+$universe_width, 70+$universe_height, 0xffffffff, 0)
		
		### Draw the instructions
		@font.draw("Press W to Unpause/Pause", $window_width/2-50, 10, 2)
		@font.draw("Press Arrow Keys to Move camera", $window_width/2-50, 30, 2)
		
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
	
end

# show the window
window = GameWindow.new
window.show