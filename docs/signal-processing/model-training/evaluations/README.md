# Evaluation reports

Identify the frozen [experiment and baseline](../experiments/README.md), their thresholds, and the exact split manifest revision or digest. Evaluate both on the same reserved **test** recordings with the frozen event-matching rule. Report the generalization claim, grouping unit, and number of independent test groups alongside the recording count.

For each detector, report detected events, missed events, false alarms, and observed duration. Compute recall as detected events divided by detected plus missed events, and false alarms per minute as false alarms divided by observed minutes.

If inspecting test results prompts a change to either system or the scoring rule, record that comparison as exploratory. Freeze the revised choices and use fresh independent test groups for the next final report.
