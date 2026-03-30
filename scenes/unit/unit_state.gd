class_name UnitState extends State

const IDLE = "Idle"
const WALK = "Walk"
const RUNNING = "Running"
const JUMPING = "Jumping"
const FALLING = "Falling"

var unit: Unit


func _ready() -> void:
	await owner.ready
	unit = owner as Unit
	assert(unit != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
