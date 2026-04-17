from collections import deque

def is_reachable(maze, start, end):
    rows = len(maze)
    cols = len(maze[0])

    directions = [(1,0), (-1,0), (0,1), (0,-1)]

    visited = set()
    queue = deque([start])

    visited.add(start)

    while queue:
        r, c = queue.popleft()

        if (r, c) == end:
            return True

        for dr, dc in directions:
            nextRow, nextCol = r + dr, c + dc

            if 0 <= nextRow < rows and 0 <= nextCol < cols:
                if maze[nextRow][nextCol] != '#' and (nextRow, nextCol) not in visited:
                    visited.add((nextRow, nextCol))
                    queue.append((nextRow, nextCol))

    return False




maze = []

print("Enter the maze structure:")
while True:
    line = input()
    if line == "":
        break
    maze.append(line)

# print(maze)

start = None
end = None

for r in range(len(maze)):
    for c in range(len(maze[r])):
        if maze[r][c] == 'S':
            start = (r, c)
        elif maze[r][c] == 'G':
            end = (r, c)

print("The start position is : " , start)
print("The goal position is : " , end)

if is_reachable(maze,start,end) :
    print("Yes")
else :
    print("No")