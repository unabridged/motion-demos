module RestorationInitialize
  def start
    # tile index
    @index = {}
    @index[RestoConstants::WATER] = "water"
    @index[RestoConstants::DIRT] = "dirt"
    @index[RestoConstants::GRASS] = "grass"
    @index[RestoConstants::TREE] = "tree"
    @index[RestoConstants::BERRIES] = "berries"
    @index[RestoConstants::CRACKED] = "cracked"

    # starting resources
    @berries = 0
    @seeds = 4
    @saplings = 5
    @saplings_to_give = 0
    @seeds_to_give = 0

    # view / ui
    @selected = 0
    @board_size = 15
    @zoom = 3
    @view_size = 11

    center = (board_size - view_size)/2
    @view_corner = (board_size*center) + center

    # modals
    @show_info = 0
    @show_intro_msg = 1
    @show_win_msg = 0

    @time_passed = 0
    @won = 0
  end
end
