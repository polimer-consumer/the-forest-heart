extends Node2D

@onready var ambient_sound = $AmbientForestSound
@onready var tilemap = $TileMap

@export var lake_scene = preload("res://subscenes/lake.tscn")
@export var noise_texture: NoiseTexture2D
var noise: Noise
var cell_size: Vector2i = Vector2i(16, 16)

var water_source_id = 0
var land_source_id = 2
var rocks_source_id = 3
var tree_source_id = 1
var dead_tree_source_id = 4

var dead_tree_atlas = Vector2i(0, 0)
var water_atlas = Vector2i(1, 1)
var grass_atlas = Vector2i(1, 1)
var dust_atlas = Vector2i(5, 2)
var flower_atlas = Vector2i(3, 0)
var tree_atlas_coords = [
	Vector2i(0, 0), Vector2i(4, 0), Vector2i(8, 0),
	Vector2i(12, 0), Vector2i(16, 0), Vector2i(20, 0),
	Vector2i(0, 7), Vector2i(4, 7), Vector2i(8, 7),
	Vector2i(12, 7), Vector2i(16, 7), Vector2i(20, 7)
]
var flower_atlas_coords = [
	Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
	Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
	Vector2i(3, 2), Vector2i(4, 2), Vector2i(4, 3),
	Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3),
	Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4)
]
var rocks_atlas_coords = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1),
	Vector2i(0, 2), Vector2i(1, 1), Vector2i(1, 2),
	Vector2i(1, 3), Vector2i(3, 2), Vector2i(4, 2),
]

var lake_top_left = Vector2i(0, 0)
var lake_left = Vector2i(0, 1)
var lake_down_left = Vector2i(0, 2)
var lake_down = Vector2i(1, 2)
var lake_down_right = Vector2i(2, 2)
var lake_right = Vector2i(2, 1)
var lake_top_right = Vector2i(2, 0)
var lake_top = Vector2i(1, 0)
var lake_left_right = Vector2i(3, 1)
var lake_top_left_right = Vector2i(3, 0)
var lake_down_left_right = Vector2i(3, 2)
var lake_top_down = Vector2i(1, 3)
var lake_top_down_left = Vector2i(0, 3)
var lake_top_down_right = Vector2i(2, 3)
var lake_inside_top_left = Vector2i(6, 2)
var lake_inside_top_right = Vector2i(5, 2)
var lake_inside_down_left = Vector2i(6, 1)
var lake_inside_down_right = Vector2i(5, 1)
var num_lakes = 10
var lake_positions = []

func _ready():
	noise = noise_texture.noise
	_generate_world()
	_generate_lakes()
	_generate_trees()
	_generate_props()
	ambient_sound.play()

func _generate_world():
	var width = 256
	var height = 256

	for x in range(width):
		for y in range(height):
			var noise_value = noise.get_noise_2d(x, y)
			if noise_value > 0.2:
				tilemap.set_cell(0, Vector2i(x, y), land_source_id, dust_atlas)
			else:
				tilemap.set_cell(0, Vector2i(x, y), land_source_id, grass_atlas)


func _generate_lakes():
	var width = 256
	var height = 256

	for i in range(num_lakes):
		var lake_points = []
		var lake = generate_polygon()
		var lake_size = randi_range(10, 20)
		for k in range(0, lake.size()):
			lake[k] = lake[k] * lake_size
		var lake_position = Vector2i(randi_range(0, width), randi_range(0, height))
		fill_lake_on_map(lake, lake_position)
		for point in lake:
			lake_points.append(point + Vector2(lake_position))
		if lake_points.size() > 0:
			var lake_instance = lake_scene.instantiate()
			lake_instance.position = lake_points[0]
			add_child(lake_instance)
			
			var polygon_points = PackedVector2Array(lake_points)
			for j in range(0, polygon_points.size()):
				polygon_points[j] = polygon_points[j] * cell_size.x
			
			var shift = Vector2(lake_position.x, lake_position.y)
			for j in range(0, polygon_points.size()):
				polygon_points[j] = polygon_points[j] - shift
				
			var polygon_centroid = centroid(polygon_points)
			for j in range(0, polygon_points.size()):
				polygon_points[j] = polygon_points[j] - polygon_centroid
				polygon_points[j] = polygon_points[j] * (1.0 + 2.0 / lake_size)
				polygon_points[j] = polygon_points[j] + polygon_centroid
			
			lake_instance.get_node("CollisionPolygon2D").polygon = polygon_points
			lake_instance.create_water_sound(polygon_centroid)
			lake_positions.append(lake_position + Vector2i(shift.x / 16, shift.y / 16))


func _generate_trees():
	var width = 256
	var height = 256
	var min_distance = 6

	for x in range(width):
		for y in range(height):
			var noise_value = noise.get_noise_2d(x, y)
			var distance_to_lake = calculate_distance_to_lake(Vector2(x, y))

			if tilemap.get_cell_source_id(0, Vector2i(x, y)) == water_source_id:
				continue

			if noise_value <= 0.2:
				if distance_to_lake < 60 and randi() % 100 < (-0.5 * distance_to_lake + 32):
					if check_min_distance(Vector2i(x, y), min_distance):
						var tree_atlas = tree_atlas_coords[randi() % tree_atlas_coords.size()]
						tilemap.set_cell(1, Vector2i(x, y), tree_source_id, tree_atlas)
				elif randi() % 100 < 2:
					if check_min_distance(Vector2i(x, y), min_distance):
						var tree_atlas = tree_atlas_coords[randi() % tree_atlas_coords.size()]
						tilemap.set_cell(1, Vector2i(x, y), tree_source_id, tree_atlas)
			else:
				if randi() % 100 < 1:
					if check_min_distance(Vector2i(x, y), min_distance):
						var tree_atlas = tree_atlas_coords[randi() % tree_atlas_coords.size()]
						tilemap.set_cell(1, Vector2i(x, y), tree_source_id, tree_atlas)
				elif randi() % 100 < 1:
					if check_min_distance(Vector2i(x, y), min_distance):
						tilemap.set_cell(1, Vector2i(x, y), dead_tree_source_id, dead_tree_atlas)


func _generate_props():
	var width = 256
	var height = 256
	
	for x in range(width):
		for y in range(height):
			var position = Vector2i(x, y)
			if tilemap.get_cell_source_id(0, position) == water_source_id \
			or tilemap.get_cell_source_id(1, position) == tree_source_id \
			or tilemap.get_cell_source_id(1, position) == dead_tree_source_id:
				continue
			
			if (tilemap.get_cell_source_id(0, position) == land_source_id \
			and tilemap.get_cell_atlas_coords(0, position) == dust_atlas):
				if randi() % 100 < 2:
					var rock_atlas = rocks_atlas_coords[randi() % rocks_atlas_coords.size()]
					tilemap.set_cell(1, position, rocks_source_id, rock_atlas)
			elif randi() % 100 < 10:
				var prop_atlas = flower_atlas_coords[randi() % flower_atlas_coords.size()]
				tilemap.set_cell(1, position, land_source_id, prop_atlas)
			elif randi() % 100 < 2:
				var rock_atlas = rocks_atlas_coords[randi() % rocks_atlas_coords.size()]
				tilemap.set_cell(1, position, rocks_source_id, rock_atlas)


func calculate_distance_to_lake(position: Vector2) -> float:
	var min_distance = INF
	for lake_pos in lake_positions:
		lake_pos = Vector2(lake_pos.x, lake_pos.y)
		var distance = lake_pos.distance_to(position)
		if distance < min_distance:
			min_distance = distance
	return min_distance


func check_min_distance(position: Vector2i, min_distance: int) -> bool:
	for dx in range(-min_distance, min_distance + 1):
		for dy in range(-min_distance, min_distance + 1):
			if dx == 0 and dy == 0:
				continue
			var neighbor_pos = position + Vector2i(dx, dy)
			if tilemap.get_cell_source_id(1, neighbor_pos) == tree_source_id or tilemap.get_cell_source_id(1, neighbor_pos) == dead_tree_source_id:
				return false
	return true


func centroid(vertices):
	var x = 0.0
	var y = 0.0
	var n = vertices.size()
	var signed_area = 0.0
	
	for i in range(n):
		var x0 = vertices[i].x
		var y0 = vertices[i].y
		var x1 = vertices[(i + 1) % n].x
		var y1 = vertices[(i + 1) % n].y
		var area = (x0 * y1) - (x1 * y0)
		signed_area += area
		x += (x0 + x1) * area
		y += (y0 + y1) * area
	
	signed_area *= 0.5
	x /= 6 * signed_area
	y /= 6 * signed_area
	return Vector2(x, y)


func fill_lake_on_map(lake: Array, position: Vector2i):
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	for point in lake:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	for x in range(int(min_x) - 1, int(max_x) + 1):
		for y in range(int(min_y) - 1, int(max_y) + 1):
			var point = Vector2(x, y)
			if is_point_in_polygon(point, lake):
				var map_x = x + position.x
				var map_y = y + position.y
				tilemap.set_cell(0, Vector2i(map_x, map_y), water_source_id, water_atlas)
	
	for x in range(int(min_x) - 2, int(max_x) + 2):
		for y in range(int(min_y) - 2, int(max_y) + 2):
			var map_x = x + position.x
			var map_y = y + position.y
			var current_cell = tilemap.get_cell_source_id(0, Vector2i(map_x, map_y))

			if current_cell != water_source_id:
				continue

			var neighbors = get_neighbors(Vector2i(map_x, map_y))
			var border_tile = get_border_tile(neighbors)
			if border_tile != Vector2i(-1, -1):
				tilemap.set_cell(0, Vector2i(map_x, map_y), water_source_id, border_tile)


func get_border_tile(neighbors: Dictionary) -> Vector2i:
	if neighbors["top"] == land_source_id and neighbors["left"] == land_source_id and neighbors["right"] == land_source_id:
		return lake_top_left_right
	elif neighbors["down"] == land_source_id and neighbors["left"] == land_source_id and neighbors["right"] == land_source_id:
		return lake_down_left_right
	elif neighbors["left"] == land_source_id and neighbors["right"] == land_source_id:
		return lake_left_right
	elif neighbors["top"] == land_source_id and neighbors["down"] == land_source_id and neighbors["right"] == land_source_id:
		return lake_top_down_right
	elif neighbors["top"] == land_source_id and neighbors["down"] == land_source_id and neighbors["left"] == land_source_id:
		return lake_top_down_left
	elif neighbors["top"] == land_source_id and neighbors["down"] == land_source_id:
		return lake_top_down
	elif neighbors["top"] == land_source_id and neighbors["right"] == land_source_id:
		return lake_top_right
	elif neighbors["top"] == land_source_id and neighbors["left"] == land_source_id:
		return lake_top_left
	elif neighbors["down"] == land_source_id and neighbors["right"] == land_source_id:
		return lake_down_right
	elif neighbors["down"] == land_source_id and neighbors["left"] == land_source_id:
		return lake_down_left
	elif neighbors["top"]:
		return lake_top
	elif neighbors["down"]:
		return lake_down
	elif neighbors["left"]:
		return lake_left
	elif neighbors["right"]:
		return lake_right
	elif neighbors["top_left"]:
		return lake_inside_top_left
	elif neighbors["top_right"]:
		return lake_inside_top_right
	elif neighbors["down_left"]:
		return lake_inside_down_left
	elif neighbors["down_right"]:
		return lake_inside_down_right
	return Vector2i(-1, -1)


func get_neighbors(cell: Vector2i) -> Dictionary:
	return {
		"top": tilemap.get_cell_source_id(0, cell + Vector2i(0, -1)),
		"down": tilemap.get_cell_source_id(0, cell + Vector2i(0, 1)),
		"left": tilemap.get_cell_source_id(0, cell + Vector2i(-1, 0)),
		"right": tilemap.get_cell_source_id(0, cell + Vector2i(1, 0)),
		"top_left": tilemap.get_cell_source_id(0, cell + Vector2i(-1, -1)),
		"top_right": tilemap.get_cell_source_id(0, cell + Vector2i(1, -1)),
		"down_left": tilemap.get_cell_source_id(0, cell + Vector2i(-1, 1)),
		"down_right": tilemap.get_cell_source_id(0, cell + Vector2i(1, 1))
	}


func is_point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside = false
	var j = polygon.size() - 1
	for i in range(polygon.size()):
		var xi = polygon[i].x
		var yi = polygon[i].y
		var xj = polygon[j].x
		var yj = polygon[j].y
		var intersect = ((yi > point.y) != (yj > point.y)) and \
						(point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi)
		if intersect:
			inside = !inside
		j = i
	return inside


func generate_polygon():
	var points = generate_random_convex_polygon(20)
	points = make_polygon_concave(points, 5)
	points = smooth_polygon(points, 2)
	return points


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
