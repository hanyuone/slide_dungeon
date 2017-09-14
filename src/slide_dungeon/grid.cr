require "./tile/*"

module SlideDungeon
  class Grid
    alias Tile = Entity | Item | Block | Nil
    getter :board, :hero, :hero_coords

    @board : Array(Array(Tile))
    @hero  : Hero

    @hero_coords : Tuple(Int32, Int32)

    @spawn_time = 1

    # Get and set rows
    private def get_row(n : Int32)
      return @board[n]
    end

    private def set_row(n : Int32, row : Array(Tile))
      @board[n] = row
    end

    # Get and set columns
    private def get_col(n : Int32)
      return (0...4).map { |x| @board[x][n] }
    end

    private def set_col(n : Int32, col : Array(Tile))
      (0...4).each do |a|
        @board[a][n] = col[a]
      end
    end

    # Place an item down
    private def place_item(item : Tile, hero? : Bool = false)
      empty_tiles = [] of Tuple(Int32, Int32)

      (0...4).each do |a|
        (0...4).each do |b|
          empty_tiles.push({a, b}) if @board[a][b].nil?
        end
      end

      rand_coords = empty_tiles.sample(1)[0]
      @board[rand_coords[0]][rand_coords[1]] = item
      @hero_coords = rand_coords if hero?
    end

    # Initialise board
    private def init_board
      4.times do
        @board.push([] of Tile)
        4.times { @board[-1].push(nil) }
      end

      place_item(@hero, true)
    end

    # Initialise method
    def initialize
      @board = [] of Array(Tile)
      @hero  = Hero.new
      @hero_coords = {-1, -1}

      init_board
    end

    # Find the hero in a row
    private def find_hero(row : Array(Tile)) : Int32
      (0...row.size).each do |a|
        return a if row[a].is_a?(Hero)
      end

      return -1
    end

    # Attack all enemies in the hero's direction
    private def attack_enemies
      enemies = case @hero.direction
                when Direction::Left
                  (0...@hero_coords[1]).map { |a| {@hero_coords[0], a} }
                when Direction::Right
                  (@hero_coords[1]...4).map { |a| {@hero_coords[0], a} }
                when Direction::Up
                  (0...@hero_coords[0]).map { |a| {a, @hero_coords[1]} }
                when Direction::Down
                  (@hero_coords[0]...4).map { |a| {a, @hero_coords[1]} }
                end.not_nil!.select { |b| @board[b[0]][b[1]].is_a?(Enemy) }

      enemies.each do |coords|
        enemy = @board[coords[0]][coords[1]]
        
        if enemy.is_a?(Enemy)
          @hero.attack_enemy(enemy)
          if enemy.health <= 0
            @board[coords[0]][coords[1]] = nil

            case @hero.direction
              when Direction::Left, Direction::Right
                slide_horizontal(@hero.direction)
              when Direction::Up, Direction::Down
                slide_vertical(@hero.direction)
            end
          else
            enemy.face(@hero_coords, coords)
          end
        end
      end
    end

    private def attack_hero
      neighbours = [{0, -1, Direction::Right}, {0, 1, Direction::Left},
                    {-1, 0, Direction::Down}, {1, 0, Direction::Up}]
                     .map { |ls| {@hero_coords[0] + ls[0], @hero_coords[1] + ls[1], ls[2]} }
                     .select { |ls| 0 <= ls[0] < 4 && 0 <= ls[1] < 4 }
                     .map { |ls| [@board[ls[0]][ls[1]], ls[2]] }

      (0...neighbours.size).each do |a|
        enemy = neighbours[a][0]
        direction = neighbours[a][1]

        enemy.attack_enemy(@hero) if enemy.is_a?(Enemy) && enemy.direction == direction
      end
    end

    # Spawns an enemy
    private def spawn_enemy
      place_item(Enemy.new(1, 0, 5))
    end

    # Spawns an item
    private def spawn_item
      item_types = [HealthPotion.new, Sword.new, Shield.new]
      rand_item = item_types[rand(item_types.size)]

      place_item(rand_item)
    end

    # Spawns a block
    private def spawn_block
      place_item(Block.new(3))
    end

    # Slide the board horizontally
    private def slide_horizontal(dir : Direction)
      (0...4).each do |a|
        row = get_row(a)
        row_items = row.reject(&.nil?)
        row_nils  = [nil] * (row.size - row_items.size)
        hero_index = row_items.index(&.is_a?(Hero))

        if !hero_index.nil?
          if dir == Direction::Left
            new_row = row_items[0...(hero_index + 1)]
            items_left = row_items[(hero_index + 1)...row_items.size]

            while new_row.size > 1 && (temp = new_row[-2]) && temp.is_a?(Item)
              temp.apply(@hero)
              new_row.delete_at(-2)
              row_nils.push(nil)
            end

            while new_row.size > 1 && (temp = new_row[-2]) && temp.is_a?(Block)
              temp.durability -= 1
              
              if temp.durability.zero?
                new_row.delete_at(-2)
                row_nils.push(nil)
              else
                break
              end
            end

            row_items = new_row + items_left
          else
            items_left = row_items[0...hero_index]
            new_row = row_items[hero_index...row_items.size]

            while new_row.size > 1 && (temp = new_row[1]) && temp.is_a?(Item)
              temp.apply(@hero)
              new_row.delete_at(1)
              row_nils.push(nil)
            end

            while new_row.size > 1 && (temp = new_row[1]) && temp.is_a?(Block)
              temp.durability -= 1
              
              if temp.durability.zero?
                new_row.delete_at(1)
                row_nils.push(nil)
              else
                break
              end
            end

            row_items = items_left + new_row
          end
        end

        if dir == Direction::Left
          row = row_items + row_nils
        else
          row = row_nils + row_items
        end

        @hero_coords = {@hero_coords[0], find_hero(row)} if a == @hero_coords[0]
        set_row(a, row)
      end
    end

    private def slide_vertical(dir : Direction)
      (0...4).each do |a|
        col = get_col(a)
        col_items = col.reject(&.nil?)
        col_nils  = [nil] * (col.size - col_items.size)
        hero_index = col_items.index(&.is_a?(Hero))

        if !hero_index.nil?
          if dir == Direction::Up
            new_col = col_items[0...(hero_index + 1)]
            items_left = col_items[(hero_index + 1)...col_items.size]

            while new_col.size > 1 && (temp = new_col[-2]) && temp.is_a?(Item)
              temp.apply(@hero)
              new_col.delete_at(-2)
              col_nils.push(nil)
            end

            while new_col.size > 1 && (temp = new_col[-2]) && temp.is_a?(Block)
              temp.durability -= 1
              
              if temp.durability.zero?
                new_col.delete_at(-2)
                col_nils.push(nil)
              else
                break
              end
            end

            col_items = new_col + items_left
          else
            items_left = col_items[0...hero_index]
            new_col = col_items[hero_index...col_items.size]

            while new_col.size > 1 && (temp = new_col[1]) && temp.is_a?(Item)
              temp.apply(@hero)
              new_col.delete_at(1)
              col_nils.push(nil)
            end

            while new_col.size > 1 && (temp = new_col[1]) && temp.is_a?(Block)
              temp.durability -= 1
              
              if temp.durability.zero?
                new_col.delete_at(1)
                col_nils.push(nil)
              else
                break
              end
            end

            col_items = items_left + new_col
          end
        end

        if dir == Direction::Up
          col = col_items + col_nils
        else
          col = col_nils + col_items
        end

        @hero_coords = {find_hero(col), @hero_coords[1]} if a == @hero_coords[1]
        set_col(a, col)
      end
    end

    private def spawn_tile
      return unless @spawn_time.zero?

      rand_int = rand(10)

      case rand_int
        when 0
          spawn_block
        when 1, 2, 3
          spawn_item
        else
          spawn_enemy
      end

      @spawn_time = 5
    end

    # Slide the board in a certain direction
    def slide(dir : Direction)
      @hero.direction = dir

      case dir
        when Direction::Left, Direction::Right
          slide_horizontal(dir)
        when Direction::Up, Direction::Down
          slide_vertical(dir)
      end

      attack_enemies
      attack_hero

      @spawn_time -= 1
      spawn_tile
    end
  end
end
