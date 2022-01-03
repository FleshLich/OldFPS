extends KinematicBody

onready var anim_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager
onready var char_mover = $"Character Mover"
onready var nav : Navigation = get_parent()

enum STATES {IDLE, CHASE, ATTACK, DEAD}
var cur_state = STATES.IDLE

var player = null
var path = []

export var sight_angle: float = 45
export var turn_speed = 360.0

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	var bone_attachements = $Graphics/Armature/Skeleton.get_children()
	for bone in bone_attachements:
		for child in bone.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt")
		
	health_manager.connect("dead", self, "set_state_dead")
	char_mover.init(self)
	set_state_idle()
			
			
func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)

func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")
	
func set_state_chase():
	cur_state = STATES.CHASE
	anim_player.play("walk_loop", 0.2)

func set_state_attack():
	cur_state = STATES.ATTACK
	
func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("die")
	char_mover.freeze()
	$CollisionShape.disabled = true

func process_state_idle(delta):
	if can_see_player():
		set_state_chase()
	
func process_state_chase(delta):
	var player_pos = player.global_transform.origin
	var cur_pos = global_transform.origin
	path = nav.get_simple_path(cur_pos, player_pos)
	var goal_pos = player_pos
	if path.size() > 1:
		goal_pos = path[1]
	
	var dir = goal_pos - cur_pos
	dir.y = 0
	char_mover.set_move_vector(dir)
	
	face_dir(dir, delta)
	
func process_state_attack(delta):
	pass
	
func process_state_dead(delta):
	pass

func hurt(damage: int, dir: Vector3):
	if cur_state == STATES.IDLE:
		set_state_chase()
	health_manager.hurt(damage, dir)

func can_see_player():
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z # Depends on whether forwards for the monster is positive or negative z
	return rad2deg(forwards.angle_to(dir_to_player)) <= sight_angle and has_los_player()

func has_los_player():
	var cur_pos = global_transform.origin + Vector3.UP
	var player_pos = player.global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(cur_pos, player_pos, [], 1)
	if result:
		return false
	return true
	
func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z)
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_right

func alert(check_los=true):
	if cur_state != STATES.IDLE:
		return
	if check_los and not has_los_player():
		return
	set_state_chase()
