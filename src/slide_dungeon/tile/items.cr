module SlideDungeon
  class Item
    getter :name, :fn, :in_inv
    @name : String
    @fn : Proc(Hero, Void)
    @in_inv : Bool

    def initialize(@name, @fn, @in_inv)
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
      in_inv = true

      super name, fn, in_inv
    end
  end

  class Sword < Item
    def initialize
      name = "Sword"
      fn = ->(hero : Hero) {
        hero.attack += 1
      }
      in_inv = false

      super name, fn, in_inv
    end
  end

  class Shield < Item
    def initialize
      name = "Shield"
      fn = ->(hero : Hero) {
        hero.defense += 1
      }
      in_inv = false

      super name, fn, in_inv
    end
  end
end