from parser import SequentialScan


def parse_plan(plan, start=False):

    PARSER_MAP = {
        "Seq Scan": SequentialScan.sequential_scan,
    }

    node = plan["Node Type"]
    if node in PARSER_MAP:
        parser = PARSER_MAP[node]
    else:
        parser = None  # Add default parser
    parsed_plan = parser(plan, start)
    return parsed_plan
