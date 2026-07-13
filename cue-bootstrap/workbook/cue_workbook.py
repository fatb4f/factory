import marimo

__generated_with = "0.14.0"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    from qualification.assertions import pilot_assertions
    from qualification.evaluate import evaluate, parity
    from qualification.orchestrator import run_cue_py, run_go
    return evaluate, mo, parity, pilot_assertions, run_cue_py, run_go


@app.cell
def _(mo):
    mo.md(
        """
        # CUE single-pattern bootstrap

        This notebook is the executable iteration record for issue #109. The
        qualification table uses registered fixtures only. Free-form exploration
        must remain outside the baseline.
        """
    )
    return


@app.cell
def _(mo):
    run_button = mo.ui.run_button(label="Run registered pilot assertions")
    run_button
    return (run_button,)


@app.cell
def _(evaluate, parity, pilot_assertions, run_button, run_cue_py, run_go):
    rows = []
    if run_button.value:
        for assertion in pilot_assertions():
            py_observation = run_cue_py(assertion.request)
            go_observation = run_go(assertion.request)
            py_result = evaluate(assertion, py_observation)
            go_result = evaluate(assertion, go_observation)
            rows.append(
                {
                    "assertion": assertion.id,
                    "cue-py": py_result.passed,
                    "go": go_result.passed,
                    "parity": not parity(py_observation, go_observation),
                    "cue-py-state": py_observation.execution_state,
                    "go-state": go_observation.execution_state,
                }
            )
    return (rows,)


@app.cell
def _(mo, rows):
    if rows:
        mo.ui.table(rows)
    else:
        mo.callout("Run the registered assertions after the locked environment and native backends are available.", kind="info")
    return


if __name__ == "__main__":
    app.run()
