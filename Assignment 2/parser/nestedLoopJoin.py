from . import parser
from . import utils


def nested_loop_join(plan, start=False):
	text = ""
	start_text = parser.parse_plan(plan["Plans"][0], start)
	text += start_text
	start_text += parser.parse_plan(plan["Plans"][1])
	text += " " + start_text
	text += " the results of the nested loop join are returned in new rows."
	return text

