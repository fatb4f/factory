# Dataset descriptions

Record the dataset source, version, and label definitions. State what should be new at deployment and choose a grouping unit that tests that claim.

| Generalization claim | Grouping unit and assignment |
| --- | --- |
| New capture session on a known receiver | Use the acquisition session ID. Keep related recordings from that session together, including adjacent files from a continuous capture. |
| Previously unseen receiver site | Use the site ID. Every session and recording from that site goes into the same split. |

Assign whole groups to train, validation, or test before windowing or augmentation. Every window and derivative inherits its recording's split. Record each recording's stable ID, session ID, and group ID in the manifest. Derive these IDs from acquisition metadata. If session provenance is uncertain, keep potentially related captures together or exclude them from the comparison. See the [SigMF guide](../../sigmf.md).

In the [example manifest](example-split.json), `rec-01` and `rec-02` share a session. A later visit produced `rec-03` at the same site, so all three belong to train. Validation and test each use a different site. Pin the manifest by revision or digest before selection. If there are too few independent groups to populate all three splits, collect more groups before reporting a final comparison.

Validate the manifest from the repository root.

```sh
cue vet -c -d '#SplitManifest' contracts/rf/model-training/splits.cue \
  docs/signal-processing/model-training/datasets/example-split.json
```
