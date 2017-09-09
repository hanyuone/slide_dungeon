module SlideDungeon
  class Item
    getter :fn
    @fn : Proc(Hero, Void)

    def initialize(@fn)
    end

    def apply(hero : Hero)
      @fn.call(hero)
    end
  end

  class HealthPotion < Item
    def initialize
      fn = ->(hero : Hero) {
        hero.health += 5
        hero.health = hero.max_health if hero.health > hero.max_health
      }

      super fn
    end
  end

  class Sword < Item
    def initialize
      fn = ->(hero : Hero) {
        hero.attack += 1
      }

      super fn
    end
  end
end