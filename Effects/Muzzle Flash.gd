extends Spatial

export var flash_time = 0.05
var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = flash_time
	add_child(timer)
	timer.connect("timeout", self, "end_flash")
	hide()
	
func flash():
	timer.start()
	rotation.z = rand_range(0.0, 2*PI)
	show()
	
func end_flash():
	hide()
