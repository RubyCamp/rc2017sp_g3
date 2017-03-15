require 'dxruby'
require_relative "map"
require_relative "player_sprite"
require_relative "navigater_sprite"


module Scene1
  class Director
    attr_accessor :player

    def initialize
      @map = Map.new(File.join("images", "map.dat"))
      @player = PlayerSprite.new(0,0)
      @navigater = NavigaterSprite.new(0,1)
      @current = @map.start

      # DXRuby�ł́AWindow.loop�̏����̍Ō��ɕ`�悪�s�����邽�߁A
      # �t���O�Ǘ����ĕ`�悪�X�L�b�v�����Ȃ��悤�ɂ����B
      @init = true          # �����̃t���[�����ǂ���
      @reach_goal = false   # �S�[���ɓ��B������
      @give_up = false      # �S�[�����B�s�\�ɂȂ������ǂ���
      @reach_point = false
    end

    GIVE_UP = 1
    DESTINATION = 2
    POINT = 3
    GOAL = 4

    def player_navigater_move(destination)
      if destination == POINT
        route = @map.calc_route(@current, @map.point, true)
      elsif destination == GOAL
        route = @map.calc_route(@current, @map.goal)
      end
      if route.length == GIVE_UP
        @give_up = true
      elsif route.length == DESTINATION
        if destination == POINT
          @reach_point = true
        elsif destination == GOAL
          @reach_goal = true
          @navigater.run_forward
          @player.move_to(@map.goal)
        end
      else
        player_next = route[1] # 子カルガモが次に進む場所
        navigater_next = route[2] # 親カルガモが次に進む場所
        @player.move_to(player_next)
        @navigater.move_to(navigater_next)
        @current = player_next
      end
    end

    def play
      if @reach_goal
        puts "goal!"
        sleep 2
        Scene.set_current_scene(:ending)
      end
      if @give_up
        puts "give up!"
        sleep 2
        Scene.set_current_scene(:ending)
      end
      if @init
        @init = false
      else
        unless @reach_point
          player_navigater_move(POINT)
        else
          player_navigater_move(GOAL)
        end
      end
      unless @reach_goal
        @map.draw
        @player.draw
        @navigater.draw
      else
        @map.draw
      end
    end
  end
end
