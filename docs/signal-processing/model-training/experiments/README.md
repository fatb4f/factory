# Training recipes

Record the [split manifest](../datasets/README.md) revision or digest, software versions, random seed, and commands for the model and baseline.

1. Fit preprocessing and model parameters on **train**.
2. Use **validation** to choose features, model configuration, hyperparameters, checkpoint, and decision thresholds. Apply the same selection rule to any tunable baseline. Record the validation metric and selected settings for both systems.
3. Freeze the preprocessing, checkpoint, baseline configuration, thresholds, and event-matching rule before opening **test**. Keep test inputs, labels, and scores out of all fitting and selection decisions.

The [TorchSig guide](../../torchsig.md) illustrates a detector experiment with a threshold baseline.
