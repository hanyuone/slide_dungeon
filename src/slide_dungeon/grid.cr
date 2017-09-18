module SlideDungeon
  class Grid(T)
    @grid : Array(Array(T?))

    # Get and set rows
    def get_row(n : Int32) : Array(T?)
      return @grid[n]
    end

    def set_row(n : Int32, row : Array(T?))
      @grid[n] = row
    end

    # Get and set columns
    def get_col(n : Int32) : Array(T?)
      return (0...4).map { |x| @grid[x][n] }
    end

    def set_col(n : Int32, col : Array(T?))
      (0...4).each do |a|
        @grid[a][n] = col[a]
      end
    end

    # Initialise grid.
    private def init_grid
      (0...4).each do |x|
        @grid.push([] of T?)
        (0...4).each do |y|
          @grid[-1].push(nil)
        end
      end
    end

    def initialize
      @grid = [] of Array(T?)

      init_grid
    end

    def place_item(item : T) : Tuple(Int32, Int32)
      empty_tiles = [] of Tuple(Int32, Int32)

      (0...4).each do |a|
        (0...4).each do |b|
          empty_tiles.push({a, b}) if @grid[a][b].nil?
        end
      end

      rand_coords = empty_tiles.sample(1)[0]
      @grid[rand_coords[0]][rand_coords[1]] = item
      return rand_coords
    end

    def [](x : Int32)
      return @grid[x]
    end
  end
end