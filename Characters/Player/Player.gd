extends KinematicBody

var hotkeys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}

export var mouse_sens = .5

onready var camera = $Camera
onready var char_mover = $"Character Mover"
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager

var dead = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	char_mover.init(self)
	health_manager.init()
	health_manager.connect("dead", self, "kill")
	weapon_manager.init($Camera/FirePoint, [self])

func _process(_delta):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()
		
	if dead:
		return
		
	var move_vector = Vector3()
	
	if Input.is_action_pressed("move-forward"):
		move_vector += Vector3.FORWARD
	elif Input.is_action_pressed("move-back"):
		move_vector += Vector3.BACK
	if Input.is_action_pressed("move-right"):
		move_vector += Vector3.RIGHT
	elif Input.is_action_pressed("move-left"):
		move_vector += Vector3.LEFT
	char_mover.set_move_vector(move_vector)
	if Input.is_action_just_pressed("Jump"):
		char_mover.jump()
		
	weapon_manager.attack(Input.is_action_just_pressed("Attack"), Input.is_action_pressed("Attack"))
	

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	if event is InputEventKey and event.pressed:
		if event.scancode in hotkeys:
			weapon_manager.switch_to_weapon_slot(hotkeys[event.scancode])
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_last_weapon()
		elif event.button_index == BUTTON_WHEEL_UP:
			weapon_manager.switch_to_next_weapon()

func hurt(damage, dir):
	health_manager.hurt(damage, dir)
	
func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	char_mover.freeze()

