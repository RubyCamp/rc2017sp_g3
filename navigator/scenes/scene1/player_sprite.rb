require 'dxruby'
require_relative 'player'

class PlayerSprite < Sprite
  def initialize(x, y, image = nil)
    image = Image.load("images/player.png")
    
    super
    self.angle = 0
    @cell_x = x
    @cell_y = y 
    self.x = self.image.width * x
    self.y = self.image.height * y
  end

  def run_forward
    case self.angle
    when 0
      self.x += self.image.width
      @cell_x += 1
    when 90
      self.y += self.image.height
      @cell_y += 1
    when 180
      self.x -= self.image.width
      @cell_x -= 1
    when 270
      self.y -= self.image.height
      @cell_y -= 1
    else
      raise "invalid angle"
    end
   
  end

  def run_backward
    case self.angle
    when 0
      self.x -= self.image.width
      @cell_x -= 1
    when 90
      self.y -= self.image.height
      @cell_y -= 1
    when 180
      self.x += self.image.width
      @cell_x += 1
    when 270
      self.y += self.image.height
      @cell_y += 1
    else
      raise "invalid angle"
    end
    
  end

  def turn_right
    self.angle += 90
    adjust_angle
   
  end

  def turn_left
    self.angle -= 90
    adjust_angle
   
  end

  def close
   
  end

  def move_to(target_cell)
    return unless movable?(target_cell)
    dx = target_cell[0] - @cell_x
    dy = target_cell[1] - @cell_y
    if dx == 1
       case self.angle
       when 0
         run_forward
       when 90
         turn_left
         run_forward
       when 180
         run_backward
       when 270
         turn_right
         run_forward
       else
         raise "invalid angle"
       end
    elsif dx == -1
       case self.angle
       when 0
         run_backward
       when 90
         turn_right
         run_forward
       when 180
         run_forward
       when 270
         turn_left
         run_forward
       else
         raise "invalid angle"
       end
    elsif dy == 1
       case self.angle
       when 0
         turn_right
         run_forward
       when 90
         run_forward
       when 180
         turn_left
         run_forward
       when 270
         run_backward
       else
         raise "invalid angle"
       end
    elsif dy == -1
       case self.angle
       when 0
         turn_left
         run_forward
       when 90
         run_backword
       when 180
         turn_right
         run_forward
       when 270
         run_forward
       else
         raise "invalid angle"
       end
    end
  end

  def movable?(target_cell)
    dx = target_cell[0] - @cell_x
    dy = target_cell[1] - @cell_y
    return (dx ** 2 + dy ** 2) == 1
  end

  private
  def adjust_angle
    self.angle += 360
    self.angle %= 360
  end
end