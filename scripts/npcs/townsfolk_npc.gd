extends RefCounted
class_name TownsfolkNPC

static func get_lines(townsfolk_id: String, day: int) -> Array[String]:
	var dialogue := {
		"A": {
			1: "Nice morning for fishing. Or so I've heard.",
			2: "Saw you heading out early. That Finn character makes me nervous.",
			3: "The kelp forest smells strange today. Good kind of strange.",
			4: "Someone said they saw the shadow of something enormous, deeper down.",
			5: "Three days left! You've got this! ...probably.",
			6: "Night fishing tonight? The ghost crabs are worth it.",
			7: "Everyone's watching to see if you make it. No pressure."
		},
		"B": {
			1: "Fresh fish for sale? I mean... not yet. You just arrived.",
			2: "Finn was asking about you this morning. Didn't sound casual.",
			3: "Have you tried the coelacanth? Ancient thing. Worth a fortune.",
			4: "My cousin owed Finn once. He doesn't fish anymore.",
			5: "Deep water fishing at your stage? Respect.",
			6: "Almost there. The whole town's rooting for you.",
			7: "Go. Don't talk to me. GO."
		},
		"C": {
			1: "Debt grows faster than fish. Fun fact.",
			2: "Five percent doesn't sound like much until it's your money.",
			3: "Partial payments help. Even a little reduces tomorrow's interest.",
			4: "The deeper fish are worth three times the shallow ones. Do the math.",
			5: "Charms are underrated. Craft something before you dive today.",
			6: "Night Kelp only appears at dusk. Gather it before it's gone.",
			7: "...I can't watch. Tell me how it ends."
		}
	}
	return [String(dialogue.get(townsfolk_id, {}).get(day, "..."))]
