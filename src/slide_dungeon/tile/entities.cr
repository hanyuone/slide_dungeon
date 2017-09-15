require "./direction.cr"

module SlideDungeon
  class Entity
    property :attack, :defense, :health, :direction, :coords

    @attack  : Int32
    @defense : Int32
    @health  : Int32
    @direction : Direction

    # Set a random direction for the entity
    private def random_dir : Direction
      directions = [Direction::Left, Direction::Right,
                    Direction::Up, Direction::Down]
      return directions[rand(4)]
    end

    # Initialise entity class
    def initialize(@attack, @defense, @health)
      @direction = random_dir
    end

    # Calculate chances of an attack being "blocked"
    def blocked? : Bool
      return false if @defense.zero?

      base = 1 + 5.0 / (@defense + 5.0)
      exp = (@defense + 5.0) / 5.0
      percentage = (base ** exp - 2) / (Math::E - 2)

      rand_float = rand()
      return rand_float > percentage
    end

    # Attack another entity
    def attack_enemy(enemy : Entity)
      if enemy.blocked?
        enemy.defense -= 1
      else
        enemy.health -= @attack
      end
    end
  end

  class Hero < Entity
    property :max_health
    @max_health : Int32

    def initialize
      super 1, 1, 10
      @max_health = 10
    end
  end

  class Enemy < Entity
    def face(hero_coords : Tuple(Int32, Int32), coords : Tuple(Int32, Int32))
      @direction = if hero_coords[0] == coords[0]
                     hero_coords[1] < coords[1] ? Direction::Left : Direction::Right
                   else
                     hero_coords[0] < coords[0] ? Direction::Up : Direction::Down
                   end
    end
  end
end