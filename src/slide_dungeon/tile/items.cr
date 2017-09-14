module SlideDungeon
  class Item
    getter :name, :fn
    @name : String
    @fn : Proc(Hero, Void)

    def initialize(@name, @fn)
    end

    def apply(hero : Hero)
      @fn.call(hero)
    end
  end

  class HealthPotion < Item
    def initialize
      name = "Health Potion"
      fn = ->(hero : Hero) {
        hero.health += 5
        hero.health = hero.max_health if hero.health > hero.max_health
      }

      super name, fn
    end
  end

  class Sword < Item
    def initialize
      name = "Sword"
      fn = ->(hero : Hero) {
        hero.attack += 1
      }

      super name, fn
    end
  end
end