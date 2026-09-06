import json

class FixtureCompiler:
    pass

def compile_fixture(payload: dict[str, object]) -> str:
    return json.dumps(payload, sort_keys=True)
