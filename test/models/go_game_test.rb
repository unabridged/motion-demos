require "test_helper"

describe Go::Game do
  let(:subject) { Go::Game.new(key: "foo") }

  describe "when initialized with default options" do
    it "has a positions array of length 81 representing an empty 9x9 board" do
      assert_equal 81, subject.board.flatten.length
    end

    it "has a current player, starting with black" do
      assert_equal :black, subject.current
    end

    it "has a record of captures in the game" do
      assert_equal({"black" => 0, "white" => 0}, subject.captures)
    end
  end

  describe "when initialized with a specific size" do
    it "generates a position array with length the square of the given size" do
      subject = Go::Game.new(key: "foo", size: 19)

      assert_equal 361, subject.board.flatten.length
    end
  end

  describe "#legal_move?" do
    it "returns falsey if the position is already occupied" do
      subject.place(Go::Pos.new(0, 0))
      refute subject.legal_move?(Go::Pos.new(0, 0))
    end

    it "returns falsey if the position is a ko" do
      def subject.kos
        {black: Go::Pos.new(0, 0)}
      end

      refute subject.legal_move?(Go::Pos.new(0, 0))
    end
  end

  describe "#place" do
    it "places a stone of the current color on the given index" do
      subject.place(Go::Pos.new(0, 0))
      assert_equal Go::Stone.new(:black, Go::Pos.new(0, 0), 1), subject.board[0][0]
    end
  end

  describe "capturing stones" do
    let(:subject) { Go::Game.new(size: 3, key: "foo") }

    before do
      # make this board:
      # wht, blk, nil,
      # nil, nil, nil,
      # nil, nil, nil,

      subject.place(Go::Pos.new(0, 1))
      subject.place(Go::Pos.new(0, 0))
    end

    it "adds number of stones captured to the captures data" do
      subject.place(Go::Pos.new(1, 0))
      assert_equal 1, subject.captures["white"]
    end

    it "removes the captured stone from the board" do
      subject.place(Go::Pos.new(1, 0))
      refute subject.board[0][0]
    end
  end

  describe "#update_groups" do
    # would be better if these tests were in the UpdateGroups interactor, but here for now

    it "creates a new group if the stone is not connected to any existing groups" do
      subject.place(Go::Pos.new(0, 0))
      assert_equal [[Go::Pos.new(0, 0)]], subject.groups[:black]
    end

    it "adds a stone to an existing group if it connects to it" do
      # place a black stone
      subject.place(Go::Pos.new(0, 0))
      # make a move for white
      subject.place(Go::Pos.new(8, 8))
      # place a second black stone connected to the first
      subject.place(Go::Pos.new(0, 1))
      assert_equal [[Go::Pos.new(0, 0), Go::Pos.new(0, 1)]], subject.groups[:black]
    end

    it "merges multiple groups if the new stone connects to multiple" do
      posns = [
        Go::Pos.new(0, 1), # black
        Go::Pos.new(8, 8), # white
        Go::Pos.new(1, 0), # black
        Go::Pos.new(8, 7), # white
        Go::Pos.new(1, 2), # black
        Go::Pos.new(8, 6), # white
        Go::Pos.new(2, 1), # black
        Go::Pos.new(8, 5) # white - so its black's turn
      ]

      # this creates 4 black groups with an empty space adjacent to all of them
      # . b .
      # b . b
      # . b .
      posns.each { |p| subject.place(p) }
      assert_equal 4, subject.groups[:black].length

      # this move should connect all black groups into one
      subject.place(Go::Pos.new(1, 1))
      assert_equal [[
        Go::Pos.new(0, 1),
        Go::Pos.new(1, 0),
        Go::Pos.new(1, 2),
        Go::Pos.new(2, 1),
        Go::Pos.new(1, 1)
      ]], subject.groups[:black]
    end
  end

  describe "#liberties" do
    it "returns the number of liberties a group has" do
      assert_equal 4, subject.liberties([Go::Pos.new(1, 1)])
      assert_equal 3, subject.liberties([Go::Pos.new(0, 1)])
      assert_equal 2, subject.liberties([Go::Pos.new(0, 0)])

      subject.place(Go::Pos.new(0, 1))
      assert_equal 1, subject.liberties([Go::Pos.new(0, 0)])

      subject.place(Go::Pos.new(1, 0))
      assert_equal 0, subject.liberties([Go::Pos.new(0, 0)])
    end
  end
end
