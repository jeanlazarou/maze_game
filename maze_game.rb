#!/usr/bin/ruby1.9.1

require 'yaml'
require 'theseus'
require 'optparse'
require 'monitor'

require 'curses'

MAZE_SAVE_FILE_NAME = "saved_maze.yml"

class MazeGame
  
  def initialize width, height, maze = nil
    
    @width, @height = width, height
    
    @maze = maze
    @maze = generate_maze unless maze
    
    move_to_entrance
    
  end

  def at_exit?
    @x == @maze.width - 1 and @y == @maze.height - 1
  end
  
  def move_to_entrance
    @x = @y = 0
  end
  
  def position
    [@x, @y]
  end
  
  def north
    
    return false unless north?
    
    @y -= 1
    
    true
    
  end
  def north?
    
    return false if @y == 0
    
    c = @maze[@x, @y]
    
    return c & Theseus::Maze::N != 0
    
  end
  
  def south
    
    return false unless south?
    
    @y += 1
    
    true
    
  end
  def south?
    
    return false if @y > @maze.height
    
    c = @maze[@x, @y]
    
    return c & Theseus::Maze::S != 0
    
  end
  
  def east
    
    return false unless east?
    
    @x += 1
    
    true
    
  end
  def east?
    
    return false if @x >= @maze.width
    
    c = @maze[@x, @y]
    
    return c & Theseus::Maze::E != 0
    
  end
  
  def west
    
    return false unless west?
    
    @x -= 1
    
    true
    
  end
  def west?
    
    return false if @x == 0
    
    c = @maze[@x, @y]
    
    return c & Theseus::Maze::W != 0
    
  end
 
  def save
    File.open(MAZE_SAVE_FILE_NAME, 'w') {|f| f.write(@maze.to_yaml)}
  end
  
  def replay
    move_to_entrance
  end
  
  def new_maze
    move_to_entrance
    @maze = generate_maze
  end
  
  def generate_maze
    Theseus::OrthogonalMaze.generate(:width => @width, :height => @height)
  end
  
  def width
    @maze.width
  end
  
  def height
    @maze.height
  end
  
  def to_s
    @maze.to_s
  end
  
end
    
class MazeContoller
  
  def initialize maze_game, view
    
    @maze_game = maze_game
  
    @view = view
    @lock = Monitor.new
    
  end
  
  def play show_time = false, show_position = false

    @view.start_game @maze_game

    launch_time_thread if show_time
      
    action = nil
    
    loop do

      @lock.synchronize do
        
        process_action action
        
        @view.display_position *@maze_game.position if show_position

      end
      
      action = @view.input_action
      
    end
    
    
  end
  
  def process_action action
    
    case action
    
      when :north
        @view.move_north if @maze_game.north
      when :east
        
        if @maze_game.at_exit?
          start_maze
        else
          @view.move_east if @maze_game.east
        end
        
      when :west
        @view.move_west if @maze_game.west
      when :south
        @view.move_south if @maze_game.south
      when :save
        @maze_game.save
      when :replay
        @maze_game.replay
        @view.start_game @maze_game
      when :new
        start_maze
      when :exit
        @view.quit_game
        
    end
  
  end
  
  def start_maze
    
    @maze_game.new_maze
        
    @view.game_over
    @view.start_game @maze_game
    
    @started_at = Time.now
    
  end
  
  def launch_time_thread
    
    @started_at = Time.now
  
    Thread.new do

      loop do
        
        ellapsed_time = ((Time.new - @started_at) * 1000).to_i
        seconds = ((ellapsed_time / 1000) % 60)
        minutes = ((ellapsed_time / 1000) / 60)
        
        @lock.synchronize do
          @view.display_ellapsed_time "%02d:%02d.%02d" % [minutes, seconds, (ellapsed_time % 1000) / 10]
        end
      
        sleep 0.05
        
      end
      
    end
    
  end

end

class MazeCursesUI
  
  def start_playing
    
    @cursor_x = 1
    @cursor_y = 1
    
  end
  
  def start_game maze
    
    @maze = maze
    
    unless @init_done
    
      Curses::init_screen
      Curses::raw
      Curses::noecho

      trap(0) { Curses::echo }
      
      @init_done = true
      
    end

    start_playing
    
    @board_width = @maze.width * 2 - 1
    @board_height = @maze.height + 1

    if @ellapsed_time_win
      @ellapsed_time_win.move 8, @board_width + 10
    end
    
    @main_win = Curses::Window.new(@board_height + 10, @board_width + 40, 0, 0)
    
    @main_win.setpos(0,0)
    @main_win.addstr(@maze.to_s)
    
    @main_win.setpos(@maze.height + 2, 2)
    @main_win.addstr("Keyboard commands:
    arrow keys   to move cursor
    e            to exit
    s            to save current maze in #{MAZE_SAVE_FILE_NAME}
    r            to replay the same maze
    n            to start a new maze
    ")
    
  end
  
  def game_over
    
    @main_win.close
    
    @maze = nil
    @main_win = nil
    
  end

  def quit_game
    Curses::echo
    exit
  end
  
  def input_action
    
    @main_win.setpos(@cursor_y, @cursor_x)

    c = @main_win.getch
    
    if c == 'A'
      :north
    elsif c == 'C'
      :east
    elsif c == 'D'
      :west
    elsif c == 'B'
      :south
    elsif c == 's'
      :save
    elsif c == 'r'
      :replay
    elsif c == 'n'
      :new
    elsif c == 'e'
      :exit
    end
    
  end
  
  def move_north
    @cursor_y -= 1
  end
  
  def move_south
    @cursor_y += 1
  end
  
  def move_west
    @cursor_x -= 2
  end
  
  def move_east
    @cursor_x += 2
  end

  def display_position x, y
    @main_win.setpos(1, @board_width + 9)
    @main_win.addstr("[#{x + 1}, #{y + 1}]")
  end
  
  def display_ellapsed_time time

    @ellapsed_time_win = Curses::Window.new(1, 30, 8, @board_width + 10) unless @ellapsed_time_win
    
    @ellapsed_time_win.setpos(0, 0)
    @ellapsed_time_win.addstr(time)
    @ellapsed_time_win.refresh
    
    @main_win.setpos(@cursor_y, @cursor_x)
    @main_win.refresh
    
  end
  
end

asked_width = 20
asked_height = 20
reuse_demo = false
saved_maze = nil
show_time = false
show_position = false

parser = OptionParser.new do |opts|
  
  opts.banner = "Usage: #{$0} [options]"

  opts.separator ""
  opts.separator "Where options include:"
  
  opts.on("-d", "--demo", "Use the demo maze") do
    reuse_demo = true
  end
  
  opts.on("-t", "--time", "Display ellapsed time") do
    show_time = true
  end
  opts.on("-p", "--position", "Display cursor position") do
    show_position = true
  end
  
  opts.on("-f", "--file maze_file.yml", "Load a saved maze from the given YAML file") do |file|
    saved_maze = file
  end
  
  opts.on("-w", "--width w", "Width for the maze to generate (defaults to #{asked_width})") do |w|
    asked_width = w.to_i
  end
  opts.on("-h", "--height h", "Height for the maze to generate (defaults to #{asked_height})") do |h|
    asked_height = h.to_i
  end
  
  opts.on_tail("-?", "--help", "Show this message") do
    puts opts
    exit
  end
  
end

begin
  
  tail = parser.parse!

  unless tail.empty?
    
    $stderr.puts "Invalid options '#{tail.join(' ')}'"
    $stderr.puts
    $stderr.puts parser
    
    exit 1
    
  end
  
rescue OptionParser::ParseError => e
  
  $stderr.puts e.message.capitalize
  $stderr.puts
  $stderr.puts parser
  
  exit 1
  
end

if reuse_demo
  maze = YAML.load(File.new('demo.yml'))
elsif saved_maze
  maze = YAML.load(File.new(saved_maze))
else
  maze = nil
end

game = MazeGame.new(asked_width, asked_height, maze)

controller = MazeContoller.new(game, MazeCursesUI.new)

controller.play show_time, show_position