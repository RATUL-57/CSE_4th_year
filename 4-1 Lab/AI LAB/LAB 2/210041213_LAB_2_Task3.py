# ======================================================
#                     TASK 1
# ======================================================

graph = {
    'A': ['B', 'C'],
    'B': ['D', 'E'],
    'C': ['F'],
    'D': [],
    'E': ['F'],
    'F': []
}

def graph_heuristic(node, goal):
    """
    Estimate how close a node is to the goal.
    Lower bound = difference in number of outgoing edges.
    """
    if node == goal:
        return 0
    
    return abs(len(graph[node]) - len(graph[goal]))


# ======================================================
#                     TASK 2
# ======================================================

def manhattan(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


class TrashState:
    def __init__(self, robot_pos, trash_positions):
        self.robot_pos = robot_pos
        self.trash_positions = frozenset(trash_positions)

    def __repr__(self):
        return f"State(robot={self.robot_pos}, trash={set(self.trash_positions)})"


def trash_heuristic(state):
    """
    Estimate the distance to clean all trash.
    h = Manhattan distance to nearest trash + MST of trash points.
    """

    robot = state.robot_pos
    trash = list(state.trash_positions)

    if not trash:
        return 0

    # 1. Distance to nearest trash
    nearest = min(manhattan(robot, t) for t in trash)

    # 2. Minimum Spanning Tree among trash nodes
    if len(trash) == 1:
        return nearest

    mst_cost = 0
    visited = {trash[0]}

    while len(visited) < len(trash):
        best = float("inf")
        best_node = None
        for v in visited:
            for t in trash:
                if t not in visited:
                    d = manhattan(v, t)
                    if d < best:
                        best = d
                        best_node = t
        
        mst_cost += best
        visited.add(best_node)

    return nearest + mst_cost

#==============================================================
#==============================================================


if __name__ == "__main__":

    print("===== TASK 1 HEURISTIC DEMO =====")
    start = 'A'
    goal  = 'F'

    print(f"Heuristic(A → F) = {graph_heuristic('A', 'F')}")
    print(f"Heuristic(B → F) = {graph_heuristic('B', 'F')}")
    print(f"Heuristic(C → F) = {graph_heuristic('C', 'F')}")
    print(f"Heuristic(E → F) = {graph_heuristic('E', 'F')}")

    print("\n===== TASK 2 HEURISTIC DEMO =====")

    example_state = TrashState(
        robot_pos=(1, 1),
        trash_positions={(1, 4), (3, 6), (3, 3)}
    )

    print("State =", example_state)
    print("Heuristic =", trash_heuristic(example_state))

    print("\nDistances to each trash:")
    for t in example_state.trash_positions:
        print(f"  From robot {example_state.robot_pos} → {t} = {manhattan(example_state.robot_pos, t)}")
