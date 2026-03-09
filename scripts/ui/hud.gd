extends CanvasLayer

# hud.gd - HUD controller

@onready var money_display: Label = $MoneyDisplay
@onready var debt_display: Label = $DebtDisplay
@onready var day_display: Label = $DayDisplay
@onready var time_display: Label = $TimeDisplay
@onready var depth_meter: ProgressBar = $DepthMeter
@onready var greed_meter: ProgressBar = $GreedMeter

func _ready():
	GameState.money_changed.connect(_update_money)
	GameState.debt_changed.connect(_update_debt)
	GameState.day_changed.connect(_update_day)
	_update_all()

func _process(delta):
	_update_time()

func _update_all():
	_update_money(GameState.money)
	_update_debt(GameState.debt)
	_update_day(GameState.day)

func _update_money(amount: int):
	money_display.text = "$%d" % amount

func _update_debt(amount: int):
	debt_display.text = "Debt: $%d" % amount

func _update_day(day: int):
	day_display.text = "Day %d" % day

func _update_time():
	time_display.text = DayNightCycle.get_time_string()

func update_depth(value: float):
	depth_meter.value = value

func update_greed(value: float):
	greed_meter.value = value
