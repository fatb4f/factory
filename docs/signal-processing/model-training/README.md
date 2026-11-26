# RF model training

Define what the detector must generalize to before splitting the captures. Fit on train, choose the model and both systems' thresholds on validation, then freeze those choices before opening the reserved test set.

| Directory | What belongs here |
| --- | --- |
| [Contracts](contracts/README.md) | References to the CUE definitions used by an experiment and the types derived from them |
| [Datasets](datasets/README.md) | Dataset sources, labels, and capture groups assigned to train, validation, and test |
| [Experiments](experiments/README.md) | Reproducible recipes and validation-based selection for the model and baseline |
| [Evaluations](evaluations/README.md) | Final results for the frozen model and baseline on the same test captures |
