import heapq
from collections import deque


def uninformed_search(start_state, goal_test_fn, successor_fn,
                      cost_fn=lambda c, n: 1, strategy='bfs'):

    visited_order = []     
    visited = set()

    # frontier initialization
    if strategy == 'dfs':
        frontier = [(start_state, 0)]            
    elif strategy == 'bfs':
        frontier = deque([(start_state, 0)])     
    elif strategy == 'ucs':
        frontier = []
        heapq.heappush(frontier, (0, start_state))
    else:
        raise ValueError("Unknown strategy")

    while frontier:
        # pop from frontier
        if strategy == 'dfs':
            current, g = frontier.pop()
        elif strategy == 'bfs':
            current, g = frontier.popleft()
        else:  # ucs
            g, current = heapq.heappop(frontier)

        if current in visited:
            continue

        # mark visited
        visited.add(current)
        visited_order.append(current)

        # expand neighbors
        for neighbor in successor_fn(current):
            if neighbor not in visited:
                new_cost = g + cost_fn(current, neighbor)

                if strategy == 'ucs':
                    heapq.heappush(frontier, (new_cost, neighbor))
                else:
                    frontier.append((neighbor, new_cost))

    return visited_order


# ------------------------------
# GRAPH SEARCH SETUP
# ------------------------------
graph = {
    'A': ['B', 'C'],
    'B': ['D', 'E'],
    'C': ['F'],
    'D': ['G'],
    'E': ['F'],
    'F': []
}

def graph_successors(node):
    return graph.get(node, [])

def graph_goal_test(node):
    # not needed when outputting visited nodes,
    # but kept for compatibility
    return False


# ------------------------------
# EXAMPLE RUN
# ------------------------------
if __name__ == "__main__":
    start_state = 'A'

    visited_nodes = uninformed_search(
        start_state=start_state,
        goal_test_fn=graph_goal_test,  
        successor_fn=graph_successors,
        cost_fn=lambda c, n: 1,
        strategy='bfs'                 
    )

    print("Visited Order:", " ".join(visited_nodes))
