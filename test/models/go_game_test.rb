require "test_helper"

describe GoGame do
  let(:subject) { GoGame.new }

  describe "when initialized with default options" do
    it "has a positions array of length 81 representing an empty 9x9 board" do
      assert_equal 81, subject.board.flatten.length
    end

    it "has a current player, starting with black" do
      assert_equal :black, subject.current
    end

    it "has a record of captures in the game" do
      assert_equal({black: 0, white: 0}, subject.captures)
    end
  end

  describe "when initialized with a specific size" do
    it "generates a position array with length the square of the given size" do
      subject = GoGame.new(size: 19)

      assert_equal 361, subject.board.flatten.length
    end
  end

  describe "#next_player" do
    it "returns :white when the current player is :black" do
      assert_equal :white, subject.next_player
    end

    it "returns :black when the current player is :white" do
      subject.next_player
      assert_equal :black, subject.next_player
    end
  end

  describe "#place" do
    it "places a stone of the current color on the given index" do
      subject.place(GoGame::Pos.new(0,0))
      assert_equal GoGame::Stone.new(:black, GoGame::Pos.new(0,0), 1), subject.board[0][0]
    end

    it "returns nil if the position is already occupied" do
      subject.place(GoGame::Pos.new(0,0))
      refute subject.place(GoGame::Pos.new(0,0))
    end
  end

  describe "capturing stones" do
    let(:subject) { GoGame.new(size: 3) }

    before do
      # make this board:
      # wht, blk, nil,
      # nil, nil, nil,
      # nil, nil, nil,

      subject.place(GoGame::Pos.new(0,1))
      subject.next_player
      subject.place(GoGame::Pos.new(0,0))
      subject.next_player
    end

    it "adds number of stones captured to the captures data" do
      subject.place(GoGame::Pos.new(1,0))
      assert_equal 1, subject.captures[:white]
    end

    it "removes the captured stone from the board" do
      subject.place(GoGame::Pos.new(1,0))
      refute subject.board[0][0]
    end
  end

  describe "#update_groups" do
    it "creates a new group if the stone is not connected to any existing groups" do
      subject.place(GoGame::Pos.new(0,0))
      assert_equal [[GoGame::Pos.new(0,0)]], subject.groups[:black]
    end

    it "adds a stone to an existing group if it connects to it" do
      subject.place(GoGame::Pos.new(0,0))
      subject.place(GoGame::Pos.new(0,1))
      assert_equal [[GoGame::Pos.new(0,0), GoGame::Pos.new(0,1)]], subject.groups[:black]
    end

    it "merges multiple groups if the new stone connects to multiple" do
      posns = [
        GoGame::Pos.new(0,1),
        GoGame::Pos.new(1,0),
        GoGame::Pos.new(1,2),
        GoGame::Pos.new(2,1),
      ]

      # this creates 4 groups
      posns.each { |p| subject.place(p) }
      # just making sure this is true
      assert_equal posns.map { |p| [p] }, subject.groups[:black]

      # this move should connect all groups into one
      subject.place(GoGame::Pos.new(1,1))
      assert_equal [posns.push(GoGame::Pos.new(1,1))], subject.groups[:black]
    end
  end

  describe "#liberties" do
    it "returns the number of liberties a group has" do
      assert_equal 4, subject.liberties([GoGame::Pos.new(1,1)])
      assert_equal 3, subject.liberties([GoGame::Pos.new(0,1)])
      assert_equal 2, subject.liberties([GoGame::Pos.new(0,0)])

      subject.place(GoGame::Pos.new(0,1))
      assert_equal 1, subject.liberties([GoGame::Pos.new(0,0)])

      subject.place(GoGame::Pos.new(1,0))
      assert_equal 0, subject.liberties([GoGame::Pos.new(0,0)])
    end
  end
end
