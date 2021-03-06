extends RigidBody2D

const Planet := preload("Planet.gd")

export var accel_mul: float = 100.0
export var turn_speed: float = 100.0
export var sun_path: NodePath

onready var acceleration_sprite: Sprite = $AccelerationDisplay
onready var gravity_sprite: Sprite = $GravityDisplay
onready var planets = get_tree().get_nodes_in_group("planet")

func _ready():
	planets.erase(get_node(sun_path))

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	var x := Input.get_action_strength("right") - Input.get_action_strength("left")
	self.applied_torque = x * self.turn_speed
	var y := Input.get_action_strength("up") - Input.get_action_strength("down")
	self.applied_force = y * self.accel_mul * self.transform.basis_xform(Vector2.UP)

	self._show_indicator(self.gravity_sprite, state.total_gravity)

func _process(_delta: float) -> void:
	var strongest_gravity := 0.0
	var target_planet: Planet
	for planet in planets:
		var planet_gravity = abs(planet.calculate_gravity_strength_at(planet.position.distance_to(position)))
		if planet_gravity > strongest_gravity:
			target_planet = planet
			strongest_gravity = planet_gravity
	
	if target_planet:
		var relative_vel := self.linear_velocity - target_planet.linear_velocity
		self._show_indicator(self.acceleration_sprite, relative_vel)

func _show_indicator(sprite: Sprite, v: Vector2) -> void:
	sprite.region_rect.size.y = v.length()
	sprite.global_position = self.position + v / 2.0
	sprite.global_rotation = -v.angle_to(Vector2.UP)
