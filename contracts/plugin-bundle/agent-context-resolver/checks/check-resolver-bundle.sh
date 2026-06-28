#!/bin/sh
set -eu

cd "$(dirname "$0")/../src"

cue vet -c=false .
cue export . -e promptMatcherValidation >/dev/null
cue export . -e routeDependencyValidation >/dev/null
cue export . -e promptRouteGraphValidation >/dev/null
cue export . -e runtimeProviderExecutionBoundary >/dev/null

! cue export . -e _matcherBoundaryChecks.providerStandalone >/dev/null
! cue export . -e _matcherBoundaryChecks.dotfilesStandalone >/dev/null
! cue export . -e _routeGraphBoundaryChecks.unclosedDependencyGraph >/dev/null
! cue export . -e _runtimeBoundaryChecks.mcpAdapterRequired >/dev/null
