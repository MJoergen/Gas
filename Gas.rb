require 'gosu'
require 'matrix'
require_relative 'Ball'

class GameWindow < Gosu::Window
	
	WIDTH  = 860
	HEIGHT = 540
	
	attr_reader :circle_img
  attr_reader :univ_left, :univ_right, :univ_top, :univ_bottom
  
	def initialize
		
		super(WIDTH, HEIGHT, false)
		
    @univ_left   = 30
    @univ_right  = WIDTH - 30
    @univ_bottom = 70
    @univ_top    = HEIGHT - 70
		
		## Only two images are used in this program
		@point_img  = Gosu::Image.new(self, "media/Point2.png", true)
		@circle_img = Gosu::Image.new(self, "media/filled_circle.png", true)
		
		## Default font
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		
		## Game is paused by default. Unpause by pressing W
		@update_balls = false

		## Creates the objects
		self.restart
		
	end
  
  def rand_range(low, high)
    return rand(high-low) + low
  end
	
	def restart  #### When you press Z, this method gets called
		
		$balls = []     ### Array containing every ball object.
    ball_radius = 11.0
		
		for i in 0..39  ### Repeat 40 times
      $balls << Ball.new(self, rand_range(@univ_left + ball_radius, @univ_right - ball_radius), 
        rand_range(@univ_bottom + ball_radius, @univ_top - ball_radius),
        rand(360), rand(5.0), ball_radius, 3.14*(ball_radius**2)) ### Create the ball
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
		draw_line(@univ_left,  @univ_bottom, 0xffffffff, @univ_right, @univ_bottom, 0xffffffff, 0)
		draw_line(@univ_left,  @univ_top,    0xffffffff, @univ_right, @univ_top,    0xffffffff, 0)
		
		draw_line(@univ_left,  @univ_bottom, 0xffffffff, @univ_left,  @univ_top,    0xffffffff, 0)
		draw_line(@univ_right, @univ_bottom, 0xffffffff, @univ_right, @univ_top,    0xffffffff, 0)
		
		### Draw the instructions
		@font.draw("Press W to Unpause/Pause", (@univ_left+@univ_right)/2-100, @univ_bottom-60, 2)
		@font.draw("Press Q to single-step", (@univ_left+@univ_right)/2-100, @univ_bottom-40, 2)
		
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