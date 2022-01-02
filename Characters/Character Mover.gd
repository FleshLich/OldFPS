extends Spatial

var body: KinematicBody = null

export var move_accel : float = 4
export var max_speed : float = 25
var drag : float
export var jump_force : float = 30
export var gravity : float = 70

var pressed_jump = false
var move_vec: Vector3
var velocity : Vector3
var snap_vec : Vector3
export var ignore_rotation = false

signal movement_info

var frozen = false

func init(_body_to_move: KinematicBody):
	body = _body_to_move

func _ready():
	drag = move_accel / max_speed

func jump():
	pressed_jump = true
	
func set_move_vector(_move_vec: Vector3):
	move_vec = _move_vec.normalized()
	
func _physics_process(delta):
	if frozen:
		return
	var drag_vector = Vector3(drag, 0, drag)
	var cur_move_vec = move_vec
	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * drag_vector + gravity * Vector3.DOWN * delta
	velocity = body.move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	
	var grounded = body.is_on_floor()
	if grounded:
		velocity.y = -0.01
	if grounded and pressed_jump:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.DOWN
	pressed_jump = false
	emit_signal("movement_info", velocity, grounded)
	
func freeze():
	frozen = true
	
func unfreeze():
	frozen = false
