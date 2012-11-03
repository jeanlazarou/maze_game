include Java

import java.awt.Font
import java.awt.Color
import java.awt.Rectangle
import java.awt.KeyboardFocusManager

import java.awt.event.KeyEvent

import javax.swing.Timer
import javax.swing.JFrame
import javax.swing.JPanel

require 'screen_buffer'

class Board < JPanel
  
  FONT = Font.new('courier', Font::PLAIN, 14)
  
  def initialize
    
    @column, @line = 0, 0
  
    @last_input = nil
    @cursor = Cursor.new(self)
    
    @buffer = ScreenBuffer.new
    
    KeyboardFocusManager.current_keyboard_focus_manager.add_key_event_dispatcher do |evt|
      
      if evt.getID == KeyEvent::KEY_PRESSED
        
        case evt.getKeyCode
        when KeyEvent::VK_UP
          @last_input = 'A'
        when KeyEvent::VK_RIGHT
          @last_input = 'C'
        when KeyEvent::VK_LEFT
          @last_input = 'D'
        when KeyEvent::VK_DOWN
          @last_input = 'B'
        when KeyEvent::VK_E
          @last_input = 'e'
        when KeyEvent::VK_N
          @last_input = 'n'
        when KeyEvent::VK_R
          @last_input = 'r'
        end
        
      end
      
      true
      
    end
    
  end
  
  def input
    ch = @last_input
    @last_input = nil
    ch
  end
  
  def display_at line, column, str
    @buffer.display_at line, column, str
  end
  
  def at column, line
    
    @column, @line = column, line
    
    @cursor.blink
    
    repaint
    
  end
  
  def paintComponent g
    
    g.color = Color::BLACK
    g.fill_rect 0, 0, width, height
    
    g.font = FONT
    g.color = Color::WHITE
    
    unless @height_metics
      
      metrics = g.font_metrics
      
      @height_metics = metrics.height.to_i
      
      @cursor.width = metrics.max_advance.to_i
      @cursor.height = @height_metics

   end

    y = 0
    
    @buffer.each do |row|
      
      y += @height_metics
      
      g.drawString row, 0, y if row
      
    end
    
    @cursor.paint g, @column, @line
    
  end
  
end

class Cursor
  
  def initialize component
    
    @component = component
    
    @state_on = true
    
    @height = @width = 10
    
  end
  
  def height= height
    @height = height
  end
  def width= width
    @width = width
  end
  
  def hide
    @timer.stop
  end
  
  def blink
    
    unless @timer
    
      @timer = Timer.new(500, nil)
      @timer.initial_delay = 0
      
      @timer.add_action_listener do |evt|
        @state_on = !@state_on
        @component.repaint
      end
    
    end
    
    @timer.start
    
  end
  
  def paint g, column, line
    
    g.color = @state_on ? Color::WHITE : Color::BLACK
    
    g.fill_rect column * (@width - 1), line * @height + 5, @width - 1, @height - 4
  
  end
  
end

module Curses

  def self.addch ch
  end
  
  def self.addstr str
  end
  
  def self.beep
  end
  
  def self.cbreak
  end
  
  def self.clear
  end
  
  def self.close_screen
  end
  
  def self.closed?
  end
  
  def self.clrtoeol
  end
  
  def self.crmode
  end

  # Sets Cursor Visibility. 0: invisible 1: visible 2: very visible
  def self.curs_set p1
  end
  
  def self.delch
  end
  
  def self.deleteln
  end
  
  def self.doupdate
  end
  
  def self.echo
  end
  
  def self.flash
  end
  
  def self.getch
  end
  
  def self.getstr
  end
  
  def self.inch
  end
  
  def self.init_screen
    
    $board = Board.new
    
    $frame = JFrame.new("Swing/Curses")
    
    $frame.add $board
    $frame.background = Color::BLACK
    
    $frame.default_close_operation = JFrame::EXIT_ON_CLOSE
    $frame.set_size 800, 600
    $frame.visible = true

  end
  
  def self.insch ch
  end
  
  def self.insertln
  end
  
  def self.keyname c
  end
  
  def self.nl
  end
  
  def self.nocbreak
  end
  
  def self.nocrmode
  end
  
  def self.noecho
  end
  
  def self.nonl
  end
  
  def self.noraw
  end
  
  def self.raw
  end
  
  def self.refresh
  end
  
  def self.setpos line, column
  end
  
  def self.standend
  end
  
  def self.standout
  end
  
  def self.stdscr
  end
  
  def self.ungetch ch
  end
  
  class Window
    
    def initialize h, w, line, column
      
      @width = w
      @height = h
      @origin_line = line
      @origin_column = column
      
      @cursor_line = 0
      @cursor_column = 0
      
    end
      
    def close
      
      @empty_line = ' ' * @width unless @empty_line
      
      @height.times do |line|
        $board.display_at @origin_line + line, @origin_column, @empty_line
      end
      
    end
    
    def setpos line, column
      
      @cursor_line = line
      @cursor_column = column
      
      $board.at @origin_column + column, @origin_line + line
      
    end
    
    def addstr str
      
      line = @origin_line + @cursor_line
      
      str.each_line do |str|
        $board.display_at line, @origin_column + @cursor_column, str
        line += 1
      end
      
    end
    
    def getch
      
      loop do
        
        ch = $board.input
        
        return ch if ch
        
        sleep 0.01
        
      end
    
    end
    
    def move line, column
      @origin_line = line
      @origin_column = column
    end
  
    def refresh
      $board.repaint
    end
    
    def debug
      
      def self.addstr str
        super
      end
      
    end
    
  end
  
end
