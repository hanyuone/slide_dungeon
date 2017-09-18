require "crsfml"

require "./game_grid.cr"
require "./tile/direction.cr"

module SlideDungeon
  class Window
    @grid : GameGrid
    @window : SF::RenderWindow
    @font : SF::Font

    @paused : Bool

    private def pause
      @paused = true
    end

    private def resume
      @paused = false
    end

    private def slide_grid(event : SF::Keyboard::Key)
      case event
        when SF::Keyboard::Left
          @grid.slide(Direction::Left)
        when SF::Keyboard::Right
          @grid.slide(Direction::Right)
        when SF::Keyboard::Up
          @grid.slide(Direction::Up)
        when SF::Keyboard::Down
          @grid.slide(Direction::Down)
      end
    end

    private def select_item(event : SF::Keyboard::Key)
      case event
        when SF::Keyboard::Num1
          @grid.use_item(0)
        when SF::Keyboard::Num2
          @grid.use_item(1)
        when SF::Keyboard::Num3
          @grid.use_item(2)
      end
    end

    private def display_grid
      board = @grid.board
      directions = {Direction::Left => "<", Direction::Right => ">", Direction::Up => "^", Direction::Down => "v"}
      item_names = {"Health Potion" => "H", "Sword" => "S", "Shield" => "Sh"}

      (0...4).each do |x|
        (0...4).each do |y|
          board_tile = board[y][x]
          x_coords = 100 + (x * 100)
          y_coords = 100 + (y * 100)

          disp_tile = SF::RectangleShape.new({100, 100})
          disp_text = SF::Text.new
          disp_text.font = @font
          disp_text.color = SF::Color::White
          
          case board_tile
            when Hero
              disp_tile.fill_color = SF.color(0, 255, 0)
              disp_text.string = "#{directions[board_tile.direction]} #{board_tile.health}"
            when Enemy
              disp_tile.fill_color = SF.color(255, 0, 0)
              disp_text.string = "#{directions[board_tile.direction]} #{board_tile.health}"
            when Item
              disp_tile.fill_color = SF.color(0, 0, 255)
              disp_text.string = "#{item_names[board_tile.name]}"
            when Block
              disp_tile.fill_color = SF.color(150, 150, 150)
          end

          disp_tile.position = {x_coords, y_coords}
          disp_text.position = {x_coords, y_coords}
          @window.draw(disp_tile)
          @window.draw(disp_text)
        end
      end
    end

    private def display_stats
      attack_text = SF::Text.new
      attack_text.font = @font
      attack_text.string = "ATK: #{@grid.hero.attack}"

      defense_text = SF::Text.new
      defense_text.font = @font
      defense_text.string = "DEF: #{@grid.hero.defense}"

      stat_one = SF::Text.new
      stat_one.font = @font
      stat_one.string = "INV 1: #{@grid.inventory.size > 0 ? @grid.inventory[0].name : "None"}"

      stat_two = SF::Text.new
      stat_two.font = @font
      stat_two.string = "INV 2: #{@grid.inventory.size > 1 ? @grid.inventory[1].name : "None"}"

      stat_three = SF::Text.new
      stat_three.font = @font
      stat_three.string = "INV 3: #{@grid.inventory.size > 2 ? @grid.inventory[2].name : "None"}"

      attack_text.position = {550, 100}
      defense_text.position = {550, 150}
      stat_one.position = {550, 200}
      stat_two.position = {550, 250}
      stat_three.position = {550, 300}

      @window.draw(attack_text)
      @window.draw(defense_text)
      @window.draw(stat_one)
      @window.draw(stat_two)
      @window.draw(stat_three)
    end

    private def draw_pause_bars
      left_bar = SF::RectangleShape.new({60, 200})
      left_bar.position = {290, 200}
      left_bar.fill_color = SF::Color::White

      right_bar = SF::RectangleShape.new({60, 200})
      right_bar.position = {410, 200}
      right_bar.fill_color = SF::Color::White

      @window.draw(left_bar)
      @window.draw(right_bar)
    end

    private def main_loop
      while @window.open?
        while (event = @window.poll_event)
          case event
            when SF::Event::Closed
              @window.close
            when SF::Event::LostFocus
              pause
            when SF::Event::GainedFocus
              resume
            when SF::Event::KeyPressed
              case event.code
                when SF::Keyboard::Up, SF::Keyboard::Down, SF::Keyboard::Left, SF::Keyboard::Right
                  slide_grid(event.code)
                when SF::Keyboard::Num1, SF::Keyboard::Num2, SF::Keyboard::Num3
                  select_item(event.code)
              end
          end
        end

        if @grid.hero.health <= 0
          return
        end

        @window.clear(SF::Color::Black)

        display_grid
        display_stats

        if @paused
          pause_rect = SF::RectangleShape.new({800, 600})
          pause_rect.fill_color = SF::Color.new(150, 150, 150, 200)
          @window.draw(pause_rect)

          draw_pause_bars
        end

        @window.display
      end
    end

    def initialize
      @grid = GameGrid.new
      @window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "Slide Dungeon")
      @font = SF::Font.from_file("resources/FiraCode-Regular.ttf")

      @paused = false

      main_loop
    end
  end
end
