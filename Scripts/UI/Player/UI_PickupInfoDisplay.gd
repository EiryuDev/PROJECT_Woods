extends Label

var lines = []
var maxLines = 5
const deleteLineAfterTime = 3.0

var deleteTimer : Timer

func _ready():
	deleteTimer = Timer.new()
	add_child(deleteTimer)
	deleteTimer.wait_time = deleteLineAfterTime
	deleteTimer.timeout.connect(DeleteLine)
	UpdateDisplay()
	
func OnPickup(pickup: Pickup):
	if pickup.pickupType == Pickup.PICKUP_TYPES.HEALTH:
		AddLine("Picked Up %s Health" % pickup.pickupAmount)
		return
		
	var weaponName = Pickup.WEAPONS.keys()[pickup.weaponType].capitalize()
	if pickup.pickupType == Pickup.PICKUP_TYPES.WEAPON:
		AddLine("Picked Up %s" % weaponName)
	if pickup.pickupType == Pickup.PICKUP_TYPES.AMMO:
		AddLine("Picked Up %s %s Ammo" % [pickup.pickupAmount, weaponName])

func AddLine(lineText: String):
	deleteTimer.start()
	lines.push_back(lineText)
	if lines.size() > maxLines:
		lines.pop_front()
	UpdateDisplay()

func DeleteLine():
	lines.pop_front()
	UpdateDisplay()

func UpdateDisplay():
	var s = ""
	for line in lines:
		s += line + "\n"
	text = s 
