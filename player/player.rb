require 'dxruby'
require_relative 'ev3/ev3'


class Player
  LEFT_MOTOR = "B"
  RIGHT_MOTOR = "C"
  DISTANCE_SENSOR = "4"
  COLOR_SENSOR_RIGHT = "2"
  COROR_SENSOR_LEFT = "1"
  PORT = "COM4"
  WHEEL_SPEED = 30

  attr_reader :distance

  def on_road?(brick)
    6 != brick.get_sensor(COLOR_SENSOR, 2)
  end

  def initialize
    @brick = EV3::Brick.new(EV3::Connections::Bluetooth.new(PORT))
    @brick.connect
    @busy = false
    @grabbing = false
  end

  # 前進する
  def run_forward(speed=WHEEL_SPEED)
    operate do
      @brick.step_velocity(speed, 38, 40, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # バックする
  def run_backward(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(*wheel_motors)
      @brick.step_velocity(speed, 0.1, 40, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # 右に回る
  def turn_right(speed=30)
    operate do
      @brick.reverse_polarity(RIGHT_MOTOR)
      @brick.step_velocity(speed, 130, 60, *wheel_motors)#130
      @brick.motor_ready(*wheel_motors)
    end
  end

  # 左に回る
  def turn_left(speed=30)
    operate do
      @brick.reverse_polarity(LEFT_MOTOR)
      @brick.step_velocity(speed, 130, 60, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  def get_count(motor)
    @brick.get_count(motor)
  end

  # 動きを止める
  def stop
    @brick.stop(true, *all_motors)
    @brick.run_forward(*all_motors)
  end

  # ある動作中は別の動作を受け付けないようにする
  def operate
    unless @busy
      @busy = true
      yield(@brick)
      stop
      @busy = false
    end
  end

  # センサー情報の更新
  def update
    dis = []
    20.times do |i|
     dis[i]=@brick.get_sensor(DISTANCE_SENSOR, 0)
    end
    @distance = dis.max_by {|value| dis.count(value)}
    p distance

  end
  #1セル進む

  def run_forward_onecell
    p "onecell"
  i = 0
  while i <= 1
    update
    if distance > 12 #&& distance < 60 
      run_forward
      @brick.step_velocity(20, 25, 10, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
      i += 1
    else
    end
  end

  end

  #曲がるときの左右首ふりで進行方向決定
  def serch
    turn_left
    update
    if distance > 50
	   turn_right
	   turn_right
    end

    #count = 0
    #while
    #  count += 1
    #  if count % 2 == 0
    #    count.times do |i|
    #      turn_left
    #    end
    #  else
    #    count.times do |i|
    #      turn_right
    #    end
    #  end
    #  update
    #  if distance < 60
    #    break
    #  end

    #end

  end

  # センサー情報の更新とキー操作受け付け
  def run
  	font = Font.new(32)
    update
    if distance > 11 && distance < 50
    	Window.draw_font(100, 300, "run_forward", font, color: [70,30,20],scale_x:1.5,scale_y:1.5)
    	run_forward
    elsif distance >= 50
    	Window.draw_font(100, 300, "onecell", font,color: [70,30,20],scale_x:1.5,scale_y:1.5)
    	run_forward_onecell
    	serch
    elsif distance < 9
      run_backward
    end
  end

  # 終了処理
  def close
    stop
    @brick.clear_all
    @brick.disconnect
  end

  def reset
    @brick.clear_all
    #motors = wheel_motors  if motors.empty?
    #@brick.reset(*motors)
  end

  # "～_MOTOR" という名前の定数すべての値を要素とする配列を返す
  def all_motors
    @all_motors ||= self.class.constants.grep(/_MOTOR\z/).map{|c| self.class.const_get(c) }
  end

  def wheel_motors
    [LEFT_MOTOR, RIGHT_MOTOR]
  end

  #最初の首振り
  def look_right#右が道なら
    turn_right
  end

  def look_left#下が道なら
    turn_left
    turn_left
    
  end
end

begin
  puts "starting..."
  font = Font.new(32)
  player = Player.new
  puts "connected"
  player.look_left
  #player.look_right#マップ分かったら要変更

  #デバック表示
  Window.width   = 850
  Window.height  = 1000
  @img = Image.load("かるがも.png")
#main文
  Window.loop do
    break if Input.keyDown?(K_SPACE)
    Window.draw(0,0,@img)
    Window.draw_font(100, 150, "#{player.distance.to_i}cm", font,color: [70,30,20],scale_x:1.5,scale_y:1.5)
    player.run


  end
#main文

rescue Exception => e
  p e
  e.backtrace.each{|trace| puts trace}
# 終了処理は必ず実行する
ensure
  puts "closing..."
  player.close
  puts "finished"

end
