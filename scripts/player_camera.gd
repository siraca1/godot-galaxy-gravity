class_name PlayerCamera
extends Camera3D

@export var player: Player
@export var focus_point: Node3D
@export var offset: Vector3 = Vector3(1.5, 2.5, 5.0)
@export var snap_speed: float = 5.0


func _ready() -> void:
	Utils.set_parent(self, null)


func _physics_process(delta) -> void:
	
	var aiming = (player.global_position - focus_point.global_position).normalized()
	var new_position = Vector3(player.global_position.x + aiming.x, player.global_position.y + aiming.y, player.global_position.z + aiming.z)
	new_position += basis.x * offset.x + basis.y * offset.y + basis.z * offset.z
	var coef = delta * snap_speed * global_position.distance_to(new_position)
	global_position.x = move_toward(global_position.x, new_position.x, coef)
	global_position.y = move_toward(global_position.y, new_position.y, coef)
	global_position.z = move_toward(global_position.z, new_position.z, coef)
	
	look_at(focus_point.global_position, player.up_direction)
