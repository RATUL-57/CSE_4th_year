import heapq
from collections import deque

# ----------------------------------------------
# Generic Uninformed Search (DFS, BFS, UCS)
# ----------------------------------------------
def uninformed_search(start_state, goal_test_fn, successor_fn,
                      cost_fn=lambda c, n: 1, strategy='bfs'):

    visited = set()

    if strategy == 'dfs':
        frontier = [(start_state, [], 0)]                 # stack
    elif strategy == 'bfs':
        frontier = deque([(start_state, [], 0)])          # queue
    elif strategy == 'ucs':
        frontier = []
        heapq.heappush(frontier, (0, start_state, []))    # priority queue
    else:
        raise ValueError("Unknown strategy")

    while frontier:
        if strategy == 'dfs':
            current, path, g = frontier.pop()
        elif strategy == 'bfs':
            current, path, g = frontier.popleft()
        else:
            g, current, path = heapq.heappop(frontier)

        if current in visited:
            continue

        visited.add(current)

        if goal_test_fn(current):
            return path, current   # return endpoint too

        for (neighbor, action) in successor_fn(current):
            if neighbor not in visited:
                new_cost = g + cost_fn(current, neighbor)
                new_path = path + [action]

                if strategy == 'ucs':
                    heapq.heappush(frontier, (new_cost, neighbor, new_path))
                else:
                    frontier.append((neighbor, new_path, new_cost))

    return None, None


# -------------------------------------------------------
# Grid Parsing + Robot Successor Function
# -------------------------------------------------------
def parse_grid(world_string):
    grid = [list(row) for row in world_string.strip().split("\n")]
    start = None
    trash = set()

    for r in range(len(grid)):
        for c in range(len(grid[0])):
            if grid[r][c] == 'R':
                start = (r, c)
            elif grid[r][c] == 'T':
                trash.add((r, c))

    return grid, start, trash


def robot_successors(pos, grid):
    r, c = pos
    rows = len(grid)
    cols = len(grid[0])

    moves = [
        ((r, c - 1), "left"),
        ((r, c + 1), "right"),
        ((r - 1, c), "up"),
        ((r + 1, c), "down")
    ]

    valid = []
    for (nr, nc), action in moves:
        if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] != '#':
            valid.append(((nr, nc), action))

    return valid


# -------------------------------------------------------
# Multi-trash cleaning logic
# -------------------------------------------------------
def clean_all_trash(start_state, trash_positions, grid):
    total_actions = []
    current_pos = start_state

    # Repeat until all trash is removed
    while trash_positions:
        # Goal test for the nearest trash
        goal_test = lambda p: p in trash_positions

        actions, reached_pos = uninformed_search(
            start_state=current_pos,
            goal_test_fn=goal_test,
            successor_fn=lambda p: robot_successors(p, grid),
            cost_fn=lambda c, n: 1,
            strategy='bfs'   # BFS = shortest path
        )

        if actions is None:
            print("Trash cannot be fully reached.")
            return None

        total_actions.extend(actions)
        trash_positions.remove(reached_pos)
        current_pos = reached_pos  

    return total_actions


# -------------------------------------------------------
# Example world (multiline string)
# -------------------------------------------------------
world = """
########
#R...T.#
#..##..#
#..#..T#
########
"""

# -------------------------------------------------------
# Run
# -------------------------------------------------------
if __name__ == "__main__":
    grid, start_state, trash_positions = parse_grid(world)

    actions = clean_all_trash(start_state, trash_positions, grid)

    if actions:
        print("Actions:", ", ".join(actions))
    else:
        print("No full cleaning possible.")
