require "./direction.cr"

module SlideDungeon
  class Entity
    property :attack, :health, :direction, :coords

    @attack : Int32
    @health : Int32
    @direction : Direction

    # Set a random direction for the entity
    private def random_dir : Direction
      directions = [Direction::Left, Direction::Right,
                    Direction::Up, Direction::Down]
      return directions[rand(4)]
    end

    # Initialise entity class
    def initialize(@attack, @health)
      @direction = random_dir
    end

    # Attack another entity
    def attack_enemy(enemy : Entity)
      enemy.health -= @attack
    end
  end

  class Hero < Entity
    property :max_health
    @max_health : Int32

    def initialize
      super 1, 10
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