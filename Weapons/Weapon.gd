extends Spatial

onready var anim_player = $AnimationPlayer
onready var bullet_emitter_base = $"Bullet Emitter"
onready var bullet_emitters = $"Bullet Emitter".get_children()

export var auto = false

var fire_point: Spatial
var bodies_to_exclude: Array = []

export var damage = 5
export var ammo = 30

export var attack_rate = .2
var attack_timer: Timer
var can_attack = true

signal fired
signal out_of_ammo

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true 
	add_child(attack_timer)
	
func init(_fire_point: Spatial, _b_to_ex: Array):
	fire_point = _fire_point
	bodies_to_exclude = _b_to_ex
	for emitter in bullet_emitters:
		emitter.set_damage(damage)
		emitter.set_bodies_exclusion(bodies_to_exclude)
		
func attack(attack_just_pressed: bool, attack_held: bool):
	if !can_attack:
		return
	if auto and !attack_held:
		return
	elif !auto and !attack_just_pressed:
		return
		
	if ammo == 0:
		if attack_just_pressed:
			anim_player.play("Idle")
			emit_signal("out_of_ammo")
		return
	
	if ammo > 0:
		ammo -= 1
		
	var start_transform = bullet_emitter_base.global_transform
	bullet_emitter_base.global_transform = fire_point.global_transform
	for emitter in bullet_emitters:
		emitter.fire()
	bullet_emitter_base.global_transform = start_transform
	anim_player.stop()
	anim_player.play("Attack")
	emit_signal("fired")
	can_attack = false
	attack_timer.start()
	
func finish_attack():
	can_attack = true
	
func set_active():
	show()
	
func set_inactive():
	anim_player.play("Idle")
	hide()
