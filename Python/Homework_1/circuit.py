"""
Implement the function `perimeter`, it will calculate and return the perimeter of the given figure.
The function template is below. The function takes exactly 1 argument, which is a list of 2-element tuples
denoting the x and y coordinates of the vertex.

Example:
perimeter([(0,0), (0,1), (1,1), (1,0)]) == 4
"""

import math as m


points = [(0,0), (0,1), (1,1), (1,0)]

def perimeter(points):

    points_count = len(points)
    circuit = 0
    for i in range(points_count):
        if i == points_count-1:
            length = m.hypot(points[i][0] - points[0][0], points[i][1] - points[0][1])
            circuit += length
            return circuit
        else:
            length = m.hypot(points[i+1][0] - points[i][0], points[i+1][1] - points[i][1])
            circuit += length



print(perimeter([(0,0), (0,1), (1,1), (2,1)]))
print(perimeter([(-8,-2), (17,-2), (1,10)]))
print(perimeter([(-8,-2), (1,10), (17,-2)]))


