package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

referenceMovementPatterns: close({
	squat: gym.#MovementPattern & {
		id:    "squat"
		label: "Bilateral squat"
		plane: "sagittal"
		channels: [
			{id: "squat-hip-extension", joint: "hip", action: "extension"},
			{id: "squat-knee-extension", joint: "knee", action: "extension"},
			{id: "squat-ankle-plantarflexion", joint: "ankle", action: "plantarflexion"},
			{id: "squat-trunk-support", joint: "trunk", action: "stabilization"},
		]
		phases: [
			{id: "descent", kind: "eccentric", motion: [{joint: "hip", action: "flexion"}, {joint: "knee", action: "flexion"}, {joint: "ankle", action: "dorsiflexion"}], activeDemand: [{id: "squat-hip-extension"}, {id: "squat-knee-extension"}, {id: "squat-ankle-plantarflexion"}, {id: "squat-trunk-support"}]},
			{id: "ascent", kind: "concentric", motion: [{joint: "hip", action: "extension"}, {joint: "knee", action: "extension"}, {joint: "ankle", action: "plantarflexion"}], activeDemand: [{id: "squat-hip-extension"}, {id: "squat-knee-extension"}, {id: "squat-ankle-plantarflexion"}, {id: "squat-trunk-support"}]},
		]
	}

	splitSquat: gym.#MovementPattern & {
		id:    "split-squat"
		label: "Split-stance squat"
		plane: "sagittal"
		channels: [
			{id: "split-hip-extension", joint: "hip", action: "extension"},
			{id: "split-knee-extension", joint: "knee", action: "extension"},
			{id: "split-ankle-plantarflexion", joint: "ankle", action: "plantarflexion"},
			{id: "split-pelvic-support", joint: "pelvis", action: "stabilization"},
		]
		phases: [
			{id: "descent", kind: "eccentric", motion: [{joint: "hip", action: "flexion"}, {joint: "knee", action: "flexion"}, {joint: "ankle", action: "dorsiflexion"}], activeDemand: [{id: "split-hip-extension"}, {id: "split-knee-extension"}, {id: "split-ankle-plantarflexion"}, {id: "split-pelvic-support"}]},
			{id: "ascent", kind: "concentric", motion: [{joint: "hip", action: "extension"}, {joint: "knee", action: "extension"}], activeDemand: [{id: "split-hip-extension"}, {id: "split-knee-extension"}, {id: "split-ankle-plantarflexion"}, {id: "split-pelvic-support"}]},
		]
	}

	hinge: gym.#MovementPattern & {
		id:    "hip-hinge"
		label: "Hip hinge"
		plane: "sagittal"
		channels: [
			{id: "hinge-hip-extension", joint: "hip", action: "extension"},
			{id: "hinge-knee-flexion-support", joint: "knee", action: "flexion", mode: "isometric"},
			{id: "hinge-trunk-support", joint: "trunk", action: "stabilization"},
		]
		phases: [
			{id: "descent", kind: "eccentric", motion: [{joint: "hip", action: "flexion"}], activeDemand: [{id: "hinge-hip-extension"}, {id: "hinge-knee-flexion-support"}, {id: "hinge-trunk-support"}]},
			{id: "ascent", kind: "concentric", motion: [{joint: "hip", action: "extension"}], activeDemand: [{id: "hinge-hip-extension"}, {id: "hinge-knee-flexion-support"}, {id: "hinge-trunk-support"}]},
		]
	}

	nordic: gym.#MovementPattern & {
		id:    "nordic"
		label: "Nordic knee-flexion pattern"
		plane: "sagittal"
		channels: [
			{id: "nordic-knee-flexion", joint: "knee", action: "flexion"},
			{id: "nordic-hip-extension-support", joint: "hip", action: "extension", mode: "isometric"},
			{id: "nordic-trunk-support", joint: "trunk", action: "stabilization"},
		]
		phases: [
			{id: "lowering", kind: "eccentric", motion: [{joint: "knee", action: "extension"}], activeDemand: [{id: "nordic-knee-flexion"}, {id: "nordic-hip-extension-support"}, {id: "nordic-trunk-support"}]},
			{id: "return", kind: "concentric", motion: [{joint: "knee", action: "flexion"}], activeDemand: [{id: "nordic-knee-flexion"}, {id: "nordic-hip-extension-support"}, {id: "nordic-trunk-support"}]},
		]
	}

	reverseNordic: gym.#MovementPattern & {
		id:    "reverse-nordic"
		label: "Reverse Nordic knee-extension pattern"
		plane: "sagittal"
		channels: [
			{id: "reverse-nordic-knee-extension", joint: "knee", action: "extension"},
			{id: "reverse-nordic-hip-extension-support", joint: "hip", action: "extension", mode: "isometric"},
			{id: "reverse-nordic-trunk-support", joint: "trunk", action: "stabilization"},
		]
		phases: [
			{id: "lowering", kind: "eccentric", motion: [{joint: "knee", action: "flexion"}], activeDemand: [{id: "reverse-nordic-knee-extension"}, {id: "reverse-nordic-hip-extension-support"}, {id: "reverse-nordic-trunk-support"}]},
			{id: "return", kind: "concentric", motion: [{joint: "knee", action: "extension"}], activeDemand: [{id: "reverse-nordic-knee-extension"}, {id: "reverse-nordic-hip-extension-support"}, {id: "reverse-nordic-trunk-support"}]},
		]
	}

	plantarflexion: gym.#MovementPattern & {
		id:    "plantarflexion"
		label: "Loaded plantarflexion"
		plane: "sagittal"
		channels: [
			{id: "plantarflexion-ankle", joint: "ankle", action: "plantarflexion"},
			{id: "plantarflexion-knee-support", joint: "knee", action: "stabilization"},
		]
		phases: [
			{id: "lowering", kind: "eccentric", motion: [{joint: "ankle", action: "dorsiflexion"}], activeDemand: [{id: "plantarflexion-ankle"}, {id: "plantarflexion-knee-support"}]},
			{id: "raising", kind: "concentric", motion: [{joint: "ankle", action: "plantarflexion"}], activeDemand: [{id: "plantarflexion-ankle"}, {id: "plantarflexion-knee-support"}]},
		]
	}

	hipFlexion: gym.#MovementPattern & {
		id:    "hip-flexion"
		label: "Loaded hip flexion"
		plane: "sagittal"
		channels: [
			{id: "hip-flexion-primary", joint: "hip", action: "flexion"},
			{id: "hip-flexion-trunk-support", joint: "trunk", action: "stabilization"},
		]
		phases: [
			{id: "raise", kind: "concentric", motion: [{joint: "hip", action: "flexion"}], activeDemand: [{id: "hip-flexion-primary"}, {id: "hip-flexion-trunk-support"}]},
			{id: "lower", kind: "eccentric", motion: [{joint: "hip", action: "extension"}], activeDemand: [{id: "hip-flexion-primary"}, {id: "hip-flexion-trunk-support"}]},
		]
	}

	backExtension: gym.#MovementPattern & {
		id:    "back-extension"
		label: "Trunk and hip extension support"
		plane: "sagittal"
		channels: [
			{id: "back-extension-trunk", joint: "trunk", action: "extension"},
			{id: "back-extension-hip", joint: "hip", action: "extension"},
		]
		phases: [
			{id: "lower", kind: "eccentric", motion: [{joint: "hip", action: "flexion"}], activeDemand: [{id: "back-extension-trunk"}, {id: "back-extension-hip"}]},
			{id: "raise", kind: "concentric", motion: [{joint: "hip", action: "extension"}], activeDemand: [{id: "back-extension-trunk"}, {id: "back-extension-hip"}]},
		]
	}
})

referenceExerciseFamilies: close({
	deepSquat: gym.#ExerciseFamily & {
		id:      "atg-deep-squat"
		label:   "ATG deep squat family"
		abilities: [{id: "deep-squat-strength"}, {id: "deep-squat-control"}]
		pattern: {id: "squat"}
		axes: [
			{id: "trunk-tibia-delta", label: "Trunk inclination relative to tibia", kind: "geometry", valueType: "number", unit: "deg", difficultyEffect: "context-dependent", effects: [{relation: "transfer", from: {kind: "joint-demand", id: "squat-knee-extension"}, to: {kind: "joint-demand", id: "squat-hip-extension"}, basis: "empirical", source: "https://pmc.ncbi.nlm.nih.gov/articles/PMC10518215/", note: "Increasing trunk inclination relative to shank shifts the hip:knee moment ratio toward hip demand."}]},
			{id: "heel-elevation", label: "Heel elevation", kind: "geometry", valueType: "number", unit: "cm", difficultyEffect: "context-dependent", effects: [{relation: "decrease", target: {kind: "mobility-requirement", id: "ankle-dorsiflexion"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-how-to-keep-or-rebuild-your-squat-mobility"}, {relation: "access", target: {kind: "joint-demand", id: "squat-knee-extension"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-how-to-keep-or-rebuild-your-squat-mobility"}]},
			{id: "counterbalance-position", label: "Counterbalance reach/load placement", kind: "load-placement", valueType: "ordinal", difficultyEffect: "context-dependent", effects: [{relation: "redistribute", target: {kind: "movement-pattern", id: "squat"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-counterbalance-a-squat-skill-for-life"}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "global-demand", id: "squat"}, basis: "derived"}]},
		]
		sources: ["https://www.atgonlinecoaching.com/articles/article-counterbalance-a-squat-skill-for-life", "https://app.atgonlinecoaching.com/articles/article-my-23-physical-standards"]
	}

	splitSquat: gym.#ExerciseFamily & {
		id:      "atg-split-squat"
		label:   "ATG split squat family"
		abilities: [{id: "split-stance-knee-hip-capacity"}, {id: "split-stance-mobility"}]
		pattern: {id: "split-squat"}
		axes: [
			{id: "front-foot-elevation", label: "Front-foot elevation", kind: "geometry", valueType: "number", unit: "cm", difficultyEffect: "lower-is-harder", effects: [{relation: "decrease", target: {kind: "mobility-requirement", id: "split-stance-depth"}, basis: "source-asserted", source: "https://app.atgonlinecoaching.com/articles/article-the-beginners-atg-lifting-program"}]},
			{id: "assistance", label: "External assistance", kind: "assistance", valueType: "ordinal", difficultyEffect: "lower-is-harder", effects: [{relation: "decrease", target: {kind: "global-demand", id: "split-squat"}, basis: "source-asserted", source: "https://app.atgonlinecoaching.com/articles/article-the-beginners-atg-lifting-program"}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "global-demand", id: "split-squat"}, basis: "derived"}]},
		]
		sources: ["https://app.atgonlinecoaching.com/articles/article-the-beginners-atg-lifting-program"]
	}

	stepDown: gym.#ExerciseFamily & {
		id:      "atg-step-down"
		label:   "ATG step-down family"
		abilities: [{id: "unilateral-knee-control"}]
		pattern: {id: "split-squat"}
		axes: [
			{id: "step-height", label: "Step height", kind: "geometry", valueType: "number", unit: "cm", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "split-knee-extension"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-test-atg-simplified-step-ups-for-knee-health"}]},
			{id: "off-foot-reach", label: "Off-foot reach position", kind: "geometry", valueType: "ordinal", difficultyEffect: "context-dependent", effects: [{relation: "increase", target: {kind: "joint-demand", id: "split-knee-extension"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-every-regression-counts"}]},
			{id: "assistance", label: "External assistance", kind: "assistance", valueType: "ordinal", difficultyEffect: "lower-is-harder", effects: [{relation: "decrease", target: {kind: "global-demand", id: "split-squat"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-test-atg-simplified-step-ups-for-knee-health"}]},
		]
		sources: ["https://www.atgonlinecoaching.com/articles/article-every-regression-counts"]
	}

	rdl: gym.#ExerciseFamily & {
		id:      "full-stretch-rdl"
		label:   "Full-stretch RDL family"
		abilities: [{id: "hip-hinge-posterior-capacity"}, {id: "long-length-posterior-capacity"}]
		pattern: {id: "hip-hinge"}
		axes: [
			{id: "range", label: "Hip-hinge range", kind: "range", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "hinge-hip-extension"}, basis: "derived"}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "hinge-hip-extension"}, basis: "derived"}]},
		]
		sources: ["https://app.atgonlinecoaching.com/articles/article-structural-balance-1"]
	}

	nordic: gym.#ExerciseFamily & {
		id:      "nordic-hamstring"
		label:   "Nordic / bodyweight hamstring curl family"
		abilities: [{id: "knee-flexion-capacity"}, {id: "eccentric-knee-flexion-control"}]
		pattern: {id: "nordic"}
		axes: [
			{id: "assistance", label: "Hand/hip assistance", kind: "assistance", valueType: "ordinal", difficultyEffect: "lower-is-harder", effects: [{relation: "decrease", target: {kind: "joint-demand", id: "nordic-knee-flexion"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/ATG-article-every-regression-counts"}]},
			{id: "limb-contribution", label: "Bilateral to unilateral contribution", kind: "limb-contribution", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "nordic-knee-flexion"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/ATG-article-every-regression-counts"}]},
			{id: "range", label: "Controlled Nordic range", kind: "range", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "nordic-knee-flexion"}, basis: "derived"}]},
		]
		sources: ["https://www.atgonlinecoaching.com/articles/ATG-article-every-regression-counts"]
	}

	reverseNordic: gym.#ExerciseFamily & {
		id:      "reverse-nordic"
		label:   "Reverse Nordic family"
		abilities: [{id: "knee-extension-long-length-capacity"}]
		pattern: {id: "reverse-nordic"}
		axes: [
			{id: "range", label: "Controlled reverse-Nordic range", kind: "range", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "reverse-nordic-knee-extension"}, basis: "derived"}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "reverse-nordic-knee-extension"}, basis: "derived"}]},
		]
	}

	straightKneeCalf: gym.#ExerciseFamily & {
		id:      "straight-knee-calf-raise"
		label:   "Straight-knee calf raise family"
		abilities: [{id: "plantarflexion-straight-knee-capacity"}]
		pattern: {id: "plantarflexion"}
		axes: [
			{id: "knee-flexion-angle", label: "Knee flexion angle", kind: "configuration", valueType: "number", unit: "deg", difficultyEffect: "context-dependent", effects: [{relation: "decrease", target: {kind: "joint-demand", id: "plantarflexion-ankle"}, basis: "empirical", source: "https://pmc.ncbi.nlm.nih.gov/articles/PMC11708772/", note: "Greater knee flexion reduces plantarflexion torque and medial gastrocnemius contribution."}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "plantarflexion-ankle"}, basis: "derived"}]},
			{id: "limb-contribution", label: "Bilateral to unilateral contribution", kind: "limb-contribution", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "plantarflexion-ankle"}, basis: "derived"}]},
		]
	}

	hipFlexor: gym.#ExerciseFamily & {
		id:      "garhammer-hip-flexion"
		label:   "Garhammer / loaded hip-flexion family"
		abilities: [{id: "hip-flexion-capacity"}]
		pattern: {id: "hip-flexion"}
		axes: [
			{id: "lever-length", label: "Leg lever length", kind: "lever", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "hip-flexion-primary"}, basis: "derived"}]},
			{id: "range", label: "Hip-flexion range", kind: "range", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "hip-flexion-primary"}, basis: "derived"}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "hip-flexion-primary"}, basis: "derived"}]},
		]
	}

	backExtension: gym.#ExerciseFamily & {
		id:      "back-extension"
		label:   "Back extension family"
		abilities: [{id: "trunk-extension-capacity"}, {id: "hip-extension-support-capacity"}]
		pattern: {id: "back-extension"}
		axes: [
			{id: "range", label: "Controlled range", kind: "range", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "joint-demand", id: "back-extension-trunk"}, basis: "source-asserted", source: "https://www.atgonlinecoaching.com/articles/article-every-regression-counts-lower-back"}]},
			{id: "lever", label: "Upper-body lever / hand position", kind: "lever", valueType: "ordinal", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "global-demand", id: "back-extension"}, basis: "derived"}]},
			{id: "external-load", label: "External load", kind: "external-load", valueType: "number", unit: "kg", difficultyEffect: "higher-is-harder", effects: [{relation: "increase", target: {kind: "global-demand", id: "back-extension"}, basis: "derived"}]},
		]
		sources: ["https://www.atgonlinecoaching.com/articles/article-every-regression-counts-lower-back"]
	}
})

// Standards are intentionally represented with explicit bases before numeric
// targets are imported. These examples establish the denominator semantics.
referenceNormalizationBases: close({
	bodyMassStandard: gym.#NormalizationBasis & {
		kind: "body-mass"
		note: "Use when an external standard is expressed relative to subject body mass."
	}
	anchorAbilityStandard: gym.#NormalizationBasis & {
		kind: "anchor-ability"
		anchorAbility: {id: "deep-squat-strength"}
		note: "Use for structural-balance relationships stated relative to an anchor lift or ability."
	}
	selfBaseline: gym.#NormalizationBasis & {
		kind: "self-baseline"
		note: "Use for longitudinal adaptation when no external reference is admitted."
	}
})

referenceCapacityRelations: close({
	kneeFlexionVsExtension: gym.#CapacityRelation & {
		id:   "knee-flexion-vs-extension"
		kind: "agonist-antagonist"
		left: {
			pattern: {id: "nordic"}
			channels: [{id: "nordic-knee-flexion"}]
			normalization: {kind: "self-baseline"}
		}
		right: {
			pattern: {id: "reverse-nordic"}
			channels: [{id: "reverse-nordic-knee-extension"}]
			normalization: {kind: "self-baseline"}
		}
		comparison: "vector"
		note: "Compare normalized admitted positions, never raw rep counts between unlike exercise families."
	}

	hipVsKneeDominance: gym.#CapacityRelation & {
		id:   "squat-hip-vs-knee-demand"
		kind: "joint-sharing"
		left: {
			pattern: {id: "squat"}
			channels: [{id: "squat-hip-extension"}]
			normalization: {kind: "movement-pattern", anchorPattern: {id: "squat"}}
		}
		right: {
			pattern: {id: "squat"}
			channels: [{id: "squat-knee-extension"}]
			normalization: {kind: "movement-pattern", anchorPattern: {id: "squat"}}
		}
		comparison: "ratio"
		source: "https://pmc.ncbi.nlm.nih.gov/articles/PMC10518215/"
	}
})
