extends KinematicBody

export var mouse_sens = .5

onready var camera = $Camera
onready var char_mover = $"Character Mover"
onready var health_manager = $HealthManager

var dead = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	char_mover.init(self)
	health_manager.init()
	health_manager.connect("dead", self, "kill")

func _process(_delta):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
		
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
	

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func hurt(damage, dir):
	health_manager.hurt(damage, dir)
	
func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	char_mover.freeze()

