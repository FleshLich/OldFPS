extends Area

class_name HitBox

export var weak_spot = false
export var crit_damage_mult: float = 2
signal hurt

func hurt(damage: int, dir: Vector3):
	if weak_spot:
		emit_signal("hurt", damage * crit_damage_mult, dir)
	else:
		emit_signal("hurt", damage, dir)

func _ready():
	pass
