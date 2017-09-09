require "./slide_dungeon/*"

grid = SlideDungeon::Grid.new
pp grid.board, grid.hero_coords
grid.slide(SlideDungeon::Direction::Left)
pp grid.board, grid.hero_coords
grid.slide(SlideDungeon::Direction::Down)
pp grid.board, grid.hero_coords
grid.slide(SlideDungeon::Direction::Right)
pp grid.board, grid.hero_coords
