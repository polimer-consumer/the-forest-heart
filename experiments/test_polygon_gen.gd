extends Node2D

var points = []

# This method generates a random convex polygon with n vertices
func generate_random_convex_polygon(n: int) -> Array:
	var rand = RandomNumberGenerator.new()
	rand.randomize()

	# Generate two lists of random X and Y coordinates
	var x_pool = []
	var y_pool = []

	for i in range(n):
		x_pool.append(rand.randf())
		y_pool.append(rand.randf())

	# Sort them
	x_pool.sort()
	y_pool.sort()

	# Isolate the extreme points
	var min_x = x_pool[0]
	var max_x = x_pool[n - 1]
	var min_y = y_pool[0]
	var max_y = y_pool[n - 1]

	# Divide the interior points into two chains & Extract the vector components
	var x_vec = []
	var y_vec = []

	var last_top = min_x
	var last_bot = min_x

	for i in range(1, n - 1):
		var x = x_pool[i]

		if rand.randi_range(0, 1) == 1:
			x_vec.append(x - last_top)
			last_top = x
		else:
			x_vec.append(last_bot - x)
			last_bot = x

	x_vec.append(max_x - last_top)
	x_vec.append(last_bot - max_x)

	var last_left = min_y
	var last_right = min_y

	for i in range(1, n - 1):
		var y = y_pool[i]

		if rand.randi_range(0, 1) == 1:
			y_vec.append(y - last_left)
			last_left = y
		else:
			y_vec.append(last_right - y)
			last_right = y

	y_vec.append(max_y - last_left)
	y_vec.append(last_right - max_y)

	# Randomly pair up the X- and Y-components
	var shuffled_y_vec = y_vec.duplicate()
	for i in range(n):
		var swap_index = rand.randi_range(0, n - 1)
		var temp = shuffled_y_vec[i]
		shuffled_y_vec[i] = shuffled_y_vec[swap_index]
		shuffled_y_vec[swap_index] = temp

	# Combine the paired up components into vectors
	var vec = Array()

	for i in range(n):
		vec.append(Vector2(x_vec[i], shuffled_y_vec[i]))

	# Sort the vectors by angle
	vec.sort_custom(func(a, b): return atan2(a.y, a.x) > atan2(b.y, b.x))

	# Lay them end-to-end
	var x_final = 0.0
	var y_final = 0.0
	var min_polygon_x = 0.0
	var min_polygon_y = 0.0
	var poly_points = Array()

	for i in range(n):
		poly_points.append(Vector2(x_final, y_final))

		x_final += vec[i].x
		y_final += vec[i].y

		min_polygon_x = min(min_polygon_x, x_final)
		min_polygon_y = min(min_polygon_y, y_final)

	# Move the polygon to the original min and max coordinates
	var x_shift = min_x - min_polygon_x
	var y_shift = min_y - min_polygon_y

	for i in range(n):
		var point = poly_points[i] + Vector2(x_shift, y_shift)
		poly_points[i] = point

	return poly_points


func ccw(A: Vector2, B: Vector2, C: Vector2) -> bool:
		return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x)

func does_intersect(p1: Vector2, p2: Vector2, q1: Vector2, q2: Vector2) -> bool:
	return (ccw(p1, q1, q2) != ccw(p2, q1, q2)) and (ccw(p1, p2, q1) != ccw(p1, p2, q2))


func choice_with_probabilities(n: int, probs) -> int:
	var min_p = 1
	for p in probs:
		min_p = min(min_p, p)
	var factor = int(1.0 / min_p)
	
	var dist = []
	for i in range(len(probs)):
		for j in range(probs[i] * factor):
			dist.append(i)

	return dist[randi_range(0, len(dist) - 1)]


func sum_arr(arr):
	var sum = 0.0
	for el in arr:
		sum += el
	return sum


func make_polygon_concave(poly_points, num_concave_points):
	for t in range(num_concave_points):
		# Calculate the lengths of all edges
		var edge_lengths = []
		for i in range(len(poly_points)):
			var A = poly_points[i]
			var B = poly_points[(i + 1) % len(poly_points)]
			edge_lengths.append(A.distance_to(B))
			
		var amplified_lengths = []
		for length in edge_lengths:
			amplified_lengths.append(length * length)
		
		# Normalize edge lengths to create a probability distribution
		var total_length = sum_arr(amplified_lengths)
		var probabilities = []
		for length in amplified_lengths:
			probabilities.append(length / total_length)

		# Select an edge based on the probability distribution
		var i = choice_with_probabilities(len(poly_points), probabilities)
		var A = poly_points[i]
		var B = poly_points[(i + 1) % len(poly_points)]

		var attempts = 0
		while attempts < 100:  # Avoid infinite loops, limit attempts
			attempts += 1
			# Calculate midpoint and length of edge AB
			var mid_AB = (A + B) / 2
			var length_AB = A.distance_to(B)
			# Select a random point C within the specified range from the midpoint of AB
			var angle = randf_range(0.0, 2 * PI)
			var distance = randf_range(length_AB / 2.5, length_AB / 1.5)
			var C = Vector2(mid_AB.x + distance * cos(angle), mid_AB.y + distance * sin(angle))
			# Check the additional conditions
			if (length_AB > C.distance_to(A) and C.distance_to(A) > length_AB / 4 and
					length_AB > C.distance_to(B) and C.distance_to(B) > length_AB / 4):
				# Check if edges AC and BC intersect with any other edges
				var valid = true
				for j in range(len(poly_points)):
					var P = poly_points[j]
					var Q = poly_points[(j + 1) % len(poly_points)]
					if does_intersect(A, C, P, Q) or does_intersect(B, C, P, Q):
						valid = false
						break

				if valid:
					# Insert point C between A and B
					poly_points.insert(i + 1, C)
					break
	return poly_points


func smooth_polygon(poly_points, iterations=2):
	for t in range(iterations):
		var new_points = []
		for i in range(len(poly_points)):
			var A = poly_points[i]
			var B = poly_points[(i + 1) % len(poly_points)]
			var Q = A * 0.75 + B * 0.25
			var R = A * 0.25 + B * 0.75
			new_points.append_array([Q, R])
		poly_points = new_points
	return poly_points

# Called when the node enters the scene tree for the first time
func _ready():
	points = generate_random_convex_polygon(20)
	points = make_polygon_concave(points, 10)
	points = smooth_polygon(points, 2)
	queue_redraw() # Call update to trigger the _draw function

# Draw the polygon
func _draw():
	if points.size() > 0:
		var prev_point = points[0] * 500
		for i in range(1, points.size() + 1):
			var point = points[i % points.size()] * 500
			draw_line(prev_point, point, Color(1, 0, 0), 2)
			prev_point = point
