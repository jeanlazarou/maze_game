
class ScreenBuffer
  
  def initialize
    @content_by_row = []
  end
  
  def display_at row, col, str
    
    str = str.chomp
    
    if @content_by_row[row]
      
      if col > @content_by_row[row].length
        @content_by_row[row] << ' ' * (col - @content_by_row[row].length)
        @content_by_row[row] << str
      else
        @content_by_row[row][col, str.length] = str
      end
      
    else
      @content_by_row[row] = ' ' * col
      @content_by_row[row] << str
    end
    
  end

  def each
    @content_by_row.each {|row| yield row}
  end
  
  def to_a
    @content_by_row
  end
  
end
