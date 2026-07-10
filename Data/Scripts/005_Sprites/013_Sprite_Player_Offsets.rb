
#[FRAME1 [x,y]],[FRAME2 [x,y], etc.]
#
# exact number of pixels that the sprite needs to be moved for each frame
# add 2 pixels on even frames
module Outfit_Offsets
  BASE_OFFSET = [[0, 0], [0, 0], [0, 0], [0, 0]]


  RUN_OFFSETS_DOWN = [[0, 2], [0, 6], [0, 2], [0, 6]]
  RUN_OFFSETS_LEFT = [[-2, -2], [-2, -2], [-2, -2], [-2, -2]]
  RUN_OFFSETS_RIGHT = [[2, -2], [2, -2], [2, -2], [2, -2]]
  RUN_OFFSETS_UP = [[0, -2], [0, -2], [0, -2], [0, -2]]

  SURF_OFFSETS_DOWN = [[0, -6], [0, -4], [0, -6], [0, -4]]
  SURF_OFFSETS_LEFT = [[-2, -10], [-2, -8], [-2, -10], [-2, -8]]
  SURF_OFFSETS_RIGHT = [[2, -10], [2, -8], [2, -10], [2, -8]]
  SURF_OFFSETS_UP = [[0, -10], [0, -8], [0, -10], [0, -8]]

  DIVE_OFFSETS_DOWN = [[0, -6], [0, -4], [0, -6], [0, -4]]
  DIVE_OFFSETS_LEFT = [[6, -8], [6, -6], [6, -8], [6, -6]]
  DIVE_OFFSETS_RIGHT = [[-6, -8], [-6, -6], [-6, -8], [-6, -6]]
  DIVE_OFFSETS_UP = [[0, -2], [0, 0], [0, -2], [0, 0]]

  BIKE_OFFSETS_DOWN = [[0, -2], [2, 0], [0, -2], [-2, 0]]
  BIKE_OFFSETS_LEFT = [[-4, -4], [-2, -2], [-4, -4], [-6, -2]]
  BIKE_OFFSETS_RIGHT = [[4, -4], [2, -2], [4, -4], [6, -2]]
  BIKE_OFFSETS_UP = [[0, -2], [-2, 0], [0, -2], [2, 0]]

  FISH_OFFSETS_DOWN = [[0, -6], [0, -2], [0, -8], [2, -6]]
  FISH_OFFSETS_LEFT = [[0, -8], [-6, -6], [0, -8], [2, -8]]
  FISH_OFFSETS_RIGHT = [[0, -8], [6, -6], [0, -8], [-2, -8]]
  FISH_OFFSETS_UP = [[0, -6], [0, -6], [0, -6], [2, -4]]
end
