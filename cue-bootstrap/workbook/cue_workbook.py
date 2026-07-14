import marimo

__generated_with = "0.14.0"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    from qualification.assertions import pilot_assertions
    from qualification.evaluate import evaluate, parity
    from qualification.native import DirectSession, summarize_value
    from qualification.orchestrator import run_go, run_gopy_worker
    return (
        DirectSession,
        evaluate,
        mo,
        parity,
        pilot_assertions,
        run_go,
        run_gopy_worker,
        summarize_value,
    )


@app.cell
def _(mo):
    mo.md(
        """
        # CUE single-pattern bootstrap

        The workbook exposes two intentionally different surfaces:

        - **Interactive mode** imports the gopy extension directly and may hold
          live Go-backed `Context` and `Value` proxies in the reactive graph.
          It is fast and inspectable, but a fatal native failure can terminate
          the Marimo kernel. Interactive results are not qualification evidence.
        - **Qualified mode** executes the same gopy extension in a fresh Python
          worker process and compares its immutable observations with the
          independent `cueprobe` Go executable.
        """
    )
    return


@app.cell
def _(mo):
    cue_input = mo.ui.text_area(
        label="Interactive CUE source",
        value="x: int & >=0\nx: 2",
        rows=6,
    )
    direct_button = mo.ui.run_button(label="Compile with live gopy binding")
    mo.vstack([cue_input, direct_button])
    return cue_input, direct_button


@app.cell
def _(DirectSession, cue_input, direct_button, summarize_value):
    direct_identity = None
    direct_summary = None
    direct_value = None
    if direct_button.value:
        direct_session = DirectSession.open()
        direct_value = direct_session.compile(cue_input.value, "interactive.cue")
        direct_identity = direct_session.identity
        direct_summary = summarize_value(direct_value)
    return direct_identity, direct_summary, direct_value


@app.cell
def _(direct_identity, direct_summary, direct_value, mo):
    if direct_summary is None:
        mo.callout(
            "Build the native extension, then compile a value through the live binding.",
            kind="info",
        )
    else:
        mo.vstack(
            [
                mo.md("## Interactive native value"),
                mo.ui.table(
                    [
                        {"property": key, "value": value}
                        for key, value in direct_summary.items()
                        if key != "diagnostics"
                    ]
                ),
                mo.md(f"**Go proxy type:** `{type(direct_value).__name__}`"),
                mo.md(f"**Engine identity:** `{direct_identity}`"),
            ]
        )
    return


@app.cell
def _(mo):
    qualified_button = mo.ui.run_button(label="Run registered qualified assertions")
    qualified_button
    return (qualified_button,)


@app.cell
def _(
    evaluate,
    parity,
    pilot_assertions,
    qualified_button,
    run_go,
    run_gopy_worker,
):
    qualification_rows = []
    if qualified_button.value:
        for assertion in pilot_assertions():
            worker_observation = run_gopy_worker(assertion.request)
            go_observation = run_go(assertion.request)
            worker_result = evaluate(assertion, worker_observation)
            go_result = evaluate(assertion, go_observation)
            mismatches = parity(worker_observation, go_observation)
            qualification_rows.append(
                {
                    "assertion": assertion.id,
                    "gopy-worker": worker_result.passed,
                    "go-runner": go_result.passed,
                    "parity": not mismatches,
                    "parity-mismatches": ", ".join(mismatches),
                    "gopy-state": worker_observation.execution_state,
                    "go-state": go_observation.execution_state,
                    "engine": worker_observation.backend.engine_revision,
                }
            )
    return (qualification_rows,)


@app.cell
def _(mo, qualification_rows):
    if qualification_rows:
        mo.ui.table(qualification_rows)
    else:
        mo.callout(
            "Qualified assertions require the locked Python environment, the generated "
            "gopy extension, and the cueprobe binary.",
            kind="info",
        )
    return


if __name__ == "__main__":
    app.run()
