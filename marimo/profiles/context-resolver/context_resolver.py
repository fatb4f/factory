import marimo

__generated_with = "0.19.0"
app = marimo.App(width="full")


@app.cell
def _():
    import importlib.util
    from pathlib import Path

    import marimo as mo

    runtime_path = Path(__file__).with_name("runtime.py")
    spec = importlib.util.spec_from_file_location(
        "factory_context_runtime", runtime_path
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {runtime_path}")
    runtime = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runtime)
    return mo, runtime


@app.cell
def _():
    # Keep this cell isolated: app.run(defs=...) replaces this one definition.
    workbook_request = {
        "schema": "factory.context-request.v0",
        "event": "interactive",
        "prompt": "context resolver",
        "repo_root": ".",
        "budget": {
            "maxFragments": 12,
            "maxSteps": 8,
            "maxNodes": 48,
            "maxTokens": 6000,
        },
    }
    return (workbook_request,)


@app.cell
def _(runtime, workbook_request):
    normalized_request = runtime.normalize_request(workbook_request)
    return (normalized_request,)


@app.cell
def _(normalized_request, runtime):
    loaded_boundaries, boundary_errors = runtime.load_boundaries(
        normalized_request
    )
    return boundary_errors, loaded_boundaries


@app.cell
def _(loaded_boundaries, runtime):
    available_context_graph = runtime.build_graph(loaded_boundaries)
    return (available_context_graph,)


@app.cell
def _(available_context_graph, normalized_request, runtime):
    filtered_context_graph = runtime.filter_graph(
        available_context_graph,
        normalized_request,
    )
    return (filtered_context_graph,)


@app.cell
def _(
    available_context_graph,
    boundary_errors,
    filtered_context_graph,
    normalized_request,
    runtime,
):
    workbook_result = runtime.project_result(
        normalized_request,
        available_context_graph,
        filtered_context_graph,
        boundary_errors,
    )
    return (workbook_result,)


@app.cell
def _(mo, workbook_result):
    mo.vstack(
        [
            mo.md("# Context resolver"),
            mo.md(
                "The reactive workbook DAG filters CUE-authoritative nested "
                "context graphs into a bounded Codex packet."
            ),
            mo.json(workbook_result),
        ]
    )
    return


if __name__ == "__main__":
    app.run()
