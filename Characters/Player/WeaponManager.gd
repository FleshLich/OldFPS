extends Spatial

enum WEAPON_SLOTS {MACHETE, MGUN, SGUN, RLAUNCHER}
var slots_unlocked = {
	WEAPON_SLOTS.MACHETE: true,
	WEAPON_SLOTS.MGUN: true,
	WEAPON_SLOTS.SGUN: true,
	WEAPON_SLOTS.RLAUNCHER: true,
}

onready var weapons = $Weapons.get_children()
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_los = $AlertAreaLOS
var cur_slot = 0
var cur_weapon = null 
var fire_point: Spatial
var bodies_to_exclude: Array = []

func _ready():
	pass


func init(_fire_point: Spatial, _b_to_ex: Array):
	fire_point = _fire_point
	bodies_to_exclude = _b_to_ex
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, _b_to_ex)
			
	weapons[WEAPON_SLOTS.MGUN].connect("fired", self, "alert_nearby_enemies")
	weapons[WEAPON_SLOTS.SGUN].connect("fired", self, "alert_nearby_enemies")
	weapons[WEAPON_SLOTS.RLAUNCHER].connect("fired", self, "alert_nearby_enemies")
	
	switch_to_weapon_slot(WEAPON_SLOTS.MACHETE)

func attack(attack_just_pressed: bool, attack_held: bool):
	if cur_weapon.has_method("attack"):
		cur_weapon.attack(attack_just_pressed, attack_held)

func switch_to_next_weapon():
	cur_slot = (cur_slot + 1) % slots_unlocked.size()
	if !slots_unlocked[cur_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(cur_slot)
	
func switch_to_last_weapon():
	cur_slot = posmod((cur_slot - 1), slots_unlocked.size())
	if !slots_unlocked[cur_slot]:
		switch_to_last_weapon()
	else:
		switch_to_weapon_slot(cur_slot)
	
func switch_to_weapon_slot(slot_id: int):
	if slot_id < 0 or slot_id >= slots_unlocked.size():
		return
	if !slots_unlocked[slot_id]:
		return
	disable_all_weapons()
	cur_weapon = weapons[slot_id]
	if cur_weapon.has_method("set_active"):
		cur_weapon.set_active()
	else:
		cur_weapon.show()
	
func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()	
			
func alert_nearby_enemies():
	var nearby_enemies = alert_area_los.get_overlapping_bodies()
	for nm in nearby_enemies:
		if nm.has_method("alert"):
			nm.alert()
			
	nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nm in nearby_enemies:
		if nm.has_method("alert"):
			nm.alert(false)
