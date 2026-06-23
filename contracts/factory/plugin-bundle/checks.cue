package pluginbundle

_negativeBottomChecks: {
	codexAsAuthority:
		*(negativeFixtures.codexAsAuthority.input & #AdmissiblePluginBundle) | _

	generatedAsAuthority:
		*(negativeFixtures.generatedAsAuthority.input & #AdmissiblePluginBundle) | _

	materializationWithoutProjection:
		*(negativeFixtures.materializationWithoutProjection.input & #AdmissiblePluginBundle) | _

	unboundedHook:
		*(negativeFixtures.unboundedHook.input & #AdmissibleCodexRuntime) | _
}
