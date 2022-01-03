extends Spatial

var rocket = preload("res://Weapons/Rocket.tscn")

var bodies_to_exclude = []
export var damage: float = 1

func _ready():
	pass
	
func set_damage(_damage: int):
	damage = _damage
	
func set_bodies_exclusion(_b_to_ex: Array):
	bodies_to_exclude = _b_to_ex

func fire():
	var rocket_inst = rocket.instance()
	rocket_inst.set_bodies_exclusion(bodies_to_exclude)
	rocket_inst.global_transform = global_transform
	rocket_inst.impact_damage = damage
	get_tree().get_root().add_child(rocket_inst)
	
