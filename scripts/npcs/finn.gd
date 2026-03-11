extends RefCounted
class_name Finn

static func get_opening_lines(day: int, debt: float, paid_previous_day: bool) -> Array[String]:
	match day:
		1:
			return [
				"Ahh, our newest customer. Fresh face, empty pockets, and a fishing rod you found on the beach. Classic.",
				"Listen up: you owe me five hundred dollars. You have exactly seven days.",
				"Every day you don't pay, I add five percent. Easy math. Painful math.",
				"The fish are out there. Get to work."
			]
		2:
			if paid_previous_day:
				return [
					"You made a payment. Good. A small one, but it shows character.",
					"Don't let that become a habit of thinking small."
				]
			return [
				"Still here? I was half expecting you to flee town overnight.",
				"The interest has been added. Tick tock.",
				"You'll find the numbers on your account... unfavorable."
			]
		3:
			if debt <= 400.0:
				return [
					"Making progress. I'm almost impressed.",
					"Don't slow down now. The ocean gets more interesting the deeper you go."
				]
			return [
				"Three days gone. Your debt is going the wrong direction.",
				"I've seen this before. I don't enjoy what usually happens next.",
				"For your sake - catch something valuable today."
			]
		4:
			if debt <= 300.0:
				return [
					"Well, well. You might actually pull this off.",
					"I've had people make it this far and then choke in the final stretch.",
					"Don't be one of them."
				]
			return [
				"Four days. Half your time.",
				"I'll be honest - I'm starting to make plans for your boat.",
				"It's a nice boat. Shame if something happened to it."
			]
		5:
			if debt <= 200.0:
				return [
					"The finish line is in sight for you.",
					"Don't get cocky - I've seen people throw away a winning hand."
				]
			return [
				"Getting nervous? You should be.",
				"Two days after today. That's not a lot of fish."
			]
		6:
			if debt <= 100.0:
				return [
					"Almost done. One good haul and you're free.",
					"I almost don't want you to make it - you've been an interesting customer."
				]
			return [
				"One day left after today. I hope you have a plan.",
				"Something big. Zone 4 big, if you know what I mean."
			]
		7:
			return [
				"This is it. Last day.",
				"If the sun sets and you still owe me money...",
				"let's just say I prefer not to discuss what happens next.",
				"Go fish. Make it count."
			]
	return ["The debt is still there. So are you."]

static func get_reactive_lines(event_id: String) -> Array[String]:
	match event_id:
		"small_payment":
			return ["A trickle. Better than nothing. Barely."]
		"large_payment":
			return ["Now that's more like it. Keep that up."]
		"debt_cleared":
			return [
				"...Fine. A deal is a deal.",
				"You're paid up. Get out of my shop.",
				"...Come back if you need another loan. I'll be here."
			]
		"cant_afford":
			return [
				"Your pockets are lighter than your brain, apparently.",
				"Come back when you have actual money."
			]
		"pro_rod":
			return [
				"The deep ones. Bold choice.",
				"Bring back something worth my time."
			]
	return []

static func get_shop_bark(debt: float) -> String:
	if debt > 400.0:
		return "Still digging your hole, I see."
	if debt > 200.0:
		return "Making progress. Slowly."
	if debt > 100.0:
		return "Don't celebrate yet."
	if debt > 50.0:
		return "You might actually make it."
	return "Pay the rest, or I'll be very disappointed."
