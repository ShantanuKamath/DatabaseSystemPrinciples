import utils, parser

def set_operation(plan, start=False):
	text = parser.parse_plan(plan["Plans"][0], start) + " " + utils.get_conjuction()
	command = str(plan["Command"])
	if command == "Except All" or command == "Except":
		text += "distinct features"
	else:
		text += "similar features"
	text += " were found between the tables employing the " + plan["Node Type"] + " operation."
	return text
