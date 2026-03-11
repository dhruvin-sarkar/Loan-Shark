extends RefCounted
class_name FishermanNPC

static func get_lines(day: int) -> Array[String]:
	var lines_by_day := {
		1: [
			"New to these waters, eh? Let me tell you something.",
			"The shallow end will keep you alive. The deep end will make you rich.",
			"But the deep takes more than it gives, if you're not careful.",
			"Start slow. Learn the zones. Don't get greedy."
		],
		2: [
			"Saw you come back with a decent haul yesterday.",
			"The kelp forest isn't far if you've got the right rod.",
			"Stonefish are worth good money - nasty things, but valuable."
		],
		3: [
			"You hear that? Below the kelp there are ruins.",
			"Nobody's mapped them properly. Things live there that don't have names yet.",
			"Good money for anyone brave enough. Or foolish enough."
		],
		4: [
			"Word of advice - watch for the shark.",
			"You'll know it's coming by the colour of the water changing.",
			"Red vignette at the edge of your vision. That's your warning. Swim fast."
		],
		5: [
			"The deep. Zone Four. You considered it?",
			"You'll need a proper rod and the right bait. Luminous lures or deep-sea rigs.",
			"And go at night. That's when the real things come out."
		],
		6: [
			"One day left after today, I hear.",
			"If you've got the gear, Zone Four tonight is your best shot.",
			"Leviathan's down there. Catch it and you'll write off half your trouble."
		],
		7: [
			"Last chance. You know what to do.",
			"The deep doesn't forgive hesitation."
		]
	}
	return lines_by_day.get(day, ["The tide knows more than I do."])
