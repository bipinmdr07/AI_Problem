# class for creating left bank with missionaries and cannibals number in it
class LeftRiverBank
  attr_accessor :m_no, :c_no
  def initialize
    # missionaries number
    @m_no = 3
    # canibals number
    @c_no = 3
  end
end

# class for creating right bank with missionaryies and canibals number in it
class RightRiverBank
  attr_accessor :m_no, :c_no
  def initialize
    # missionaries number
    @m_no = 0
    # canibals number
    @c_no = 0
  end
end

# class for creating the boat with number of missionaries and canibals travelling through the boat
class Boat
  attr_accessor :m_content, :c_content, :in_left_bank
  def initialize
    @m_content = 0
    @c_content = 0
    @in_left_bank = true # true for representing that the boat is in left river bank and false for right river bank
  end
end

# base class for generating the tree data structure
class Node
  attr_accessor :children, :tot_stat, :is_visited
  def initialize (m_stat, c_stat, boat_stat)
    # array of child nodes (Node class)
    @children = []
    # stats for representing the no. of current missionaries and canibals number in left bank
    @m_stat = m_stat
    @c_stat = c_stat
    @boat_stat = boat_stat
    # array for representing the node state
    @tot_stat = [@m_stat, @c_stat, @boat_stat]
    # bool variable for keeping track if it has been printed / visited while creating tree
    @is_visited = false
  end
end

# state = [[LeftRiverBank info][RightRiverBank info]]
# in simple language state = [[m_no in left_bank, c_no in left_bank, current boat_position], [m_no in right_bank, c_no in right_bank, current boat position]]
# initial_state = [3 missionaries, 3 cannibals, boat on left_bank] in left river bank
# final_state = [0 missionaries, 0 cannibals], boat_on right_bank] in left river bank
initial_state, final_state = [[3, 3, true],[0, 0, true]], [[0, 0, false],[3, 3, false]]

# Queue
queue = [initial_state]

# Array for storing the state that has already been examinated
data = []

# create the node object with parameter m_no, n_no, boat_position in left bank
node = Node.new(initial_state[0][0],initial_state[0][1],initial_state[0][2])
left_bank = LeftRiverBank.new
right_bank = RightRiverBank.new
boat = Boat.new

# making the created node in initial_state a root node
root_node = node
parent_node = node

# creating the queue for node to connect with its child node
node_queue = [parent_node]

# method for setting the instace values to its original values as before
def set_original_value(left_bank, right_bank, boat, m, c)
  boat.in_left_bank = !boat.in_left_bank
  if boat.in_left_bank == true
    left_bank.m_no += m
    left_bank.c_no += c
    right_bank.m_no -= m
    right_bank.c_no -= c
  else
    right_bank.m_no += m
    right_bank.c_no += c
    left_bank.m_no -= m
    left_bank.c_no -= c
  end
end

# BFS algorithm
while true
  # deque the state from the queue and make it the current state
  current_state = queue.shift
  # current parent node
  current_p_node = node_queue.shift

  # continue the loop if c_no > m_no where m_no is present then this void the condition m_no >= c_no on both river banks
  # examine for another state
  # filtering the invalid state
  next if (current_state[0][1] > current_state[0][0] && current_state[0][0] != 0) || (current_state[1][1] > current_state[1][0] && current_state[1][0] != 0)

  # if final state is reached then break the loop
  break if current_state == final_state

  # storing the popuation of missionaries and cannibals on both river banks and position of the boat
  left_bank.m_no, left_bank.c_no = current_state.first[0], current_state.first[1]
  right_bank.m_no, right_bank.c_no = current_state[1][0], current_state[1][1]
  boat.in_left_bank = current_state.first.last

  # initally there are no travellers in the boat
  m_traveling, c_traveling = -1, -1

  # Boat can carray maximum of 2 passengers
  # Boat cannot travel to another bank without any passengers
  # At least one passenger is require for boat to travel to another river bank

  # finding the max number of missionaries and cannibals that can travel through boat at a time
  # either cannibals group or missionaries group but not both
  if boat.in_left_bank == true
    m_traveling = (left_bank.m_no > 2)? 2 : left_bank.m_no
    c_traveling = (left_bank.c_no > 2)? 2 : left_bank.c_no
  else
    m_traveling = (right_bank.m_no > 2)? 2 : right_bank.m_no
    c_traveling = (right_bank.c_no > 2)? 2 : right_bank.c_no
  end

  # getting the combination of cannibals and missionaries that can travel to next bank
  for m in 0..m_traveling
    for c in 0..c_traveling
      # proceed to next combination if 0 cannibals and 0 missionaries are travelling to another bank
      next if ((m + c) > 2 || (m + c) == 0)
      boat.m_content = m
      boat.c_content = c

      # after the boat has been loaded the subtract no. of missionaries and cannibals travelling from the current bank
      # and add it to other bank
      if boat.in_left_bank == true # boat is in the left bank
        left_bank.m_no -= m
        left_bank.c_no -= c
        right_bank.m_no += m
        right_bank.c_no += c
      else                        # boat is in the right bank
        left_bank.m_no += m
        left_bank.c_no += c
        right_bank.m_no -= m
        right_bank.c_no -= c
      end
      # the boat need to be on other side of the river after being loaded with passenger/s
      boat.in_left_bank = !boat.in_left_bank

      # store the tate after crossing the river in arr and enqueue it to the queue whether it's a valid state or not
      arr = [[left_bank.m_no, left_bank.c_no, boat.in_left_bank],[right_bank.m_no, right_bank.c_no, boat.in_left_bank]]
      if !data.include?(arr)
        if !queue.include?(arr)
          queue.push(arr)

          # create a Node object with state after crossing the river and make it a child of current parent node
          temp_node = Node.new(arr[0][0], arr[0][1], arr[0][2])
          current_p_node.children.push(temp_node)
          node_queue.push(temp_node)
        end
      end

      # restore the original value of all object to its previous value so the it can be tested for another possible states
      set_original_value(left_bank, right_bank, boat, m, c)
    end
  end

  # storing the copy of current_state so the no state is repeated again
  data.push(Marshal.load(Marshal.dump(current_state)))
end

# DFS algorithm
stack = []
current_node = root_node
current_node.is_visited = true
# dfs buffer is used for storing the nodes that is being expanded or has been expanded
# so that the same state doesn't get expanded more than once
dfs_buffer = []
tab = 0
while true
  
  if !dfs_buffer.include?(current_node) && tab >= 0
    prefix = '     |      '
    suffix = '     |------'
    if tab == 0
      print
    else
      print prefix * (tab - 1) + suffix
    end
    print current_node.tot_stat
    puts
  end
  if (current_node != nil)
    if !current_node.children.find{|x| x.is_visited == false}.nil?
      next_node = current_node.children.find{|x| x.is_visited == false}
      stack.push(current_node)
      dfs_buffer.push(current_node)
      next_node.is_visited = true
      current_node = next_node
      tab += 1
    else
      current_node = stack.pop
      tab -= 1
    end
  else
    break
  end
end
