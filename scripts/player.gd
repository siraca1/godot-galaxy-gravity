class_name Player
extends CharacterBody3D


#region Exported var

@export var _focus_point: Node3D = null

#endregion


#region Private var

var _camera_pivot: Node3D = null
var _camera_pivot_x: Node3D = null
var _pivot_setup: bool = false

var _movement_input: Vector2 = Vector2.ZERO

var _gravity: Vector3 = Vector3.ZERO
var _up_velocity: Vector3 = Vector3.ZERO
var _direction: Vector3 = Vector3.ZERO

var _is_jumping: bool = false

#endregion


#region Constants

const JUMP_FORCE: float = 10.0
const SPEED: float = 5.0

#endregion


#region Private functions

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_camera_pivot = Node3D.new()
	Utils.set_parent(_camera_pivot, null)
	_camera_pivot_x = Node3D.new()
	_focus_point = Node3D.new()
	await get_tree().process_frame
	
	_camera_pivot.global_position = global_position
	_camera_pivot.name = "CameraPivot"
	
	_camera_pivot.add_child(_camera_pivot_x)
	_camera_pivot_x.position = Vector3.ZERO
	_camera_pivot_x.name = "CameraPivotX"
	
	_camera_pivot_x.add_child(_focus_point)
	_focus_point.position = Vector3.FORWARD * 10.0
	_focus_point.name = "FocusPoint"
	
	_pivot_setup = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _pivot_setup:
		_camera_pivot.global_rotate(up_direction, deg_to_rad(-event.relative.x * 0.1))
		_camera_pivot_x.global_rotate(basis.x, deg_to_rad(-event.relative.y * 0.1))


func _execute_jump() -> void:
	_up_velocity = up_direction * JUMP_FORCE
	_is_jumping = true


func _process(_delta: float) -> void:
	pass
	var state := PhysicsServer3D.body_get_direct_state(get_rid())
	_gravity = state.total_gravity
	
	_camera_pivot.global_position = global_position
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_execute_jump()
	
	_movement_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func _physics_process(delta: float) -> void:
	up_direction = lerp(up_direction, -_gravity, delta)
	
	_handle_jump_physics(delta)
		
	var target_rotation = transform.looking_at(position - basis.z, up_direction).basis
	transform.basis = transform.basis.slerp(target_rotation, delta).orthonormalized()
	
	if _pivot_setup and global_position.distance_to(_focus_point.global_position) > 0.1:
		look_at(_focus_point.global_position, up_direction)
	
	_direction = (transform.basis * Vector3(_movement_input.x, 0, _movement_input.y)).normalized()
	_direction = Plane(up_direction).project(_direction).normalized()
	if _direction:
		velocity = _direction * SPEED + _up_velocity
	else:
		velocity = _up_velocity

	move_and_slide()


func _handle_jump_physics(delta: float) -> void:
	if not is_on_floor():
		_up_velocity += _gravity * delta
		_is_jumping = false
	elif not _is_jumping:
		_up_velocity = Vector3.ZERO

#endregion
