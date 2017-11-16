from . import sequentialScan, limit, general_parser, materialize


def parse_plan(plan, start=False):

    PARSER_MAP = {
        "Seq Scan": sequentialScan.sequential_scan,
        "Limit": limit.limit,
        "Materialize": materialize.materialize
    }

    node = plan["Node Type"]
    if node in PARSER_MAP:
        parser = PARSER_MAP[node]
    else:
        parser = general_parser.general_parser  # Add default parser
    parsed_plan = parser(plan, start)
    return parsed_plan
