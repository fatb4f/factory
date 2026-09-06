package industrialsignalsnegative

import domain "github.com/fatb4f/factory/contracts/world/industrial-signals:industrialsignals"

// Current event-watch execution must not unify with graph execution.
invalidGraphExecution: domain.#IndustrialGraphExecution & domain.contract.execution
