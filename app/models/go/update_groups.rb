module Go
  # Takes a game and a new position (stone/move) and connects or creates new groups as needed
  # Creating groups of stones makes it much easier to track the status of whether or not they are captured
  class UpdateGroups
    def self.call(game:, pos:)
      new(game, pos).call
    end

    attr_reader :game, :pos

    def initialize(game, pos)
      @game = game
      @pos = pos
    end

    def call
      connected_to = groups_connected_to_pos

      case connected_to.length
      when 0
        # not connected to anything, make a new group of a single stone
        groups << [pos]
      when 1
        # connect the stone to the one group it touches
        i = groups.index(connected_to.first)
        groups[i] << pos
      else
        # otherwise the stone is touching multiple groups and we should connect them all
        connect_multiple_groups(connected_to)
      end
    end

    private

    def groups_connected_to_pos
      groups.select { |g| pos.neighbors_in_bounds(size).map { |n| g.include?(n) }.any? }
    end

    # TODO: would be nice to just merge existing groups together, rather than find and delete
    def connect_multiple_groups(groups_to_connect)
      # find the groups' indexes, so we know which ones to remove
      ixs = groups_to_connect.map { |ary| groups.index(ary) }

      # create a new group with all the existing groups' stones plus the new one (pos)
      new_group = stones_in_groups(ixs) << pos

      # have to reverse here because delete_at mutates the array as we iterate and changes the indexes
      # certainly some proper functional programming would be better :P
      ixs.reverse_each { |i| groups.delete_at(i) }
      groups << new_group
    end

    def groups
      game.groups[game.current]
    end

    def size
      game.size
    end

    def stones_in_groups(group_indexes)
      group_indexes.map { |i| groups[i] }.flatten
    end
  end
end
