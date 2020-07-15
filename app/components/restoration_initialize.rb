module RestorationInitialize
  def start
    # tile index
    @index = {}
    @index[0] = "water"
    @index[1] = "dirt"
    @index[2] = "grass"
    @index[3] = "tree"
    @index[4] = "berries"
    @index[5] = "cracked"

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

    center = (@board_size - @view_size)/2
    @view_corner = (@board_size*center) + center

    # modals
    @show_info = 0
    @show_intro_msg = 1
    @show_win_msg = 0

    @time_passed = 0
    @won = 0
  end
end
