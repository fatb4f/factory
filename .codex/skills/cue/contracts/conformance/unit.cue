package conformance

import "list"

#Scenario: "positive" | "negative" | "invariant" | "compatibility" | "adversarial"
#Requirement: close({
	id: string
	dependsOn: [...string]
	acceptance: close({id: string, scenarios: {[#Scenario]: true}})
	order: int & >=0
})

// Complete P0 closure selected from issue-106-requirements-matrix:v3.
requirements: close({
	"SK-01": {dependsOn: [], acceptance: {id: "SK-01-A1", scenarios: {positive: true, invariant: true}}, order: 0}
	"LS-01": {dependsOn: ["SK-01"], acceptance: {id: "LS-01-A1", scenarios: {positive: true, compatibility: true}}, order: 1}
	"SK-02": {dependsOn: ["SK-01"], acceptance: {id: "SK-02-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 2}
	"KR-01": {dependsOn: ["SK-02"], acceptance: {id: "KR-01-A1", scenarios: {positive: true, negative: true, compatibility: true}}, order: 3}
	"KR-02": {dependsOn: ["KR-01"], acceptance: {id: "KR-02-A1", scenarios: {positive: true, negative: true}}, order: 4}
	"PK-01": {dependsOn: ["SK-02", "KR-01"], acceptance: {id: "PK-01-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 5}
	"KR-03": {dependsOn: ["KR-02"], acceptance: {id: "KR-03-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 6}
	"PK-02": {dependsOn: ["PK-01"], acceptance: {id: "PK-02-A1", scenarios: {positive: true, negative: true}}, order: 7}
	"PK-03": {dependsOn: ["PK-01", "KR-02"], acceptance: {id: "PK-03-A1", scenarios: {positive: true, negative: true}}, order: 8}
	"PK-04": {dependsOn: ["PK-01"], acceptance: {id: "PK-04-A1", scenarios: {negative: true, adversarial: true, invariant: true}}, order: 9}
	"KR-04": {dependsOn: ["KR-03"], acceptance: {id: "KR-04-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 10}
	"KR-05": {dependsOn: ["KR-03"], acceptance: {id: "KR-05-A1", scenarios: {positive: true, negative: true, adversarial: true, compatibility: true}}, order: 11}
	"LS-02": {dependsOn: ["LS-01", "PK-02"], acceptance: {id: "LS-02-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 12}
	"RN-01": {dependsOn: ["SK-01", "PK-02"], acceptance: {id: "RN-01-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 13}
	"VG-01": {dependsOn: ["PK-02", "PK-04"], acceptance: {id: "VG-01-A1", scenarios: {positive: true, negative: true}}, order: 14}
	"PR-01": {dependsOn: ["PK-03", "KR-03", "KR-04", "KR-05"], acceptance: {id: "PR-01-A1", scenarios: {positive: true, negative: true}}, order: 15}
	"RN-02": {dependsOn: ["RN-01"], acceptance: {id: "RN-02-A1", scenarios: {positive: true, negative: true, compatibility: true}}, order: 16}
	"PR-02": {dependsOn: ["PR-01", "PK-04"], acceptance: {id: "PR-02-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 17}
	"FX-02": {dependsOn: ["PR-02", "PK-04"], acceptance: {id: "FX-02-A1", scenarios: {negative: true, adversarial: true}}, order: 18}
	"PR-03": {dependsOn: ["PR-02", "PK-01"], acceptance: {id: "PR-03-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 19}
	"PR-08": {dependsOn: ["PR-02", "KR-02"], acceptance: {id: "PR-08-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 20}
	"PR-04": {dependsOn: ["PR-02", "PR-08", "KR-03", "KR-04", "KR-05"], acceptance: {id: "PR-04-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 21}
	"PR-09": {dependsOn: ["PR-03"], acceptance: {id: "PR-09-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}}, order: 22}
	"FX-01": {dependsOn: ["KR-05", "PR-04"], acceptance: {id: "FX-01-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 23}
	"PR-05": {dependsOn: ["PR-04", "PK-03"], acceptance: {id: "PR-05-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 24}
	"PR-07": {dependsOn: ["PR-03", "PR-09"], acceptance: {id: "PR-07-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 25}
	"PR-06": {dependsOn: ["PR-05", "PK-02"], acceptance: {id: "PR-06-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 26}
	"RO-01": {dependsOn: ["PR-02", "PR-03", "PR-07", "PR-09"], acceptance: {id: "RO-01-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 27}
	"RN-03": {dependsOn: ["RN-02", "PR-02", "PR-07", "RO-01"], acceptance: {id: "RN-03-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 28}
	"RO-02": {dependsOn: ["RO-01"], acceptance: {id: "RO-02-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 29}
	"RO-03": {dependsOn: ["RO-01", "PK-04"], acceptance: {id: "RO-03-A1", scenarios: {negative: true, adversarial: true}}, order: 30}
	"EV-01": {dependsOn: ["RO-02"], acceptance: {id: "EV-01-A1", scenarios: {positive: true, negative: true}}, order: 31}
	"RN-04": {dependsOn: ["RN-03", "PR-07", "PR-09", "KR-04", "KR-05", "PR-08"], acceptance: {id: "RN-04-A1", scenarios: {positive: true, negative: true, adversarial: true, invariant: true}}, order: 32}
	"VG-02": {dependsOn: ["VG-01", "RN-03", "RO-01"], acceptance: {id: "VG-02-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 33}
	"EV-04": {dependsOn: ["EV-01", "PK-03"], acceptance: {id: "EV-04-A1", scenarios: {positive: true, negative: true}}, order: 34}
	"FX-06": {dependsOn: ["PR-08", "KR-03", "RN-04"], acceptance: {id: "FX-06-A1", scenarios: {negative: true, adversarial: true}}, order: 35}
	"RN-05": {dependsOn: ["RN-03", "RN-04", "PK-02"], acceptance: {id: "RN-05-A1", scenarios: {positive: true, negative: true, adversarial: true, invariant: true}}, order: 36}
	"VG-03": {dependsOn: ["VG-02", "RN-04", "RO-03"], acceptance: {id: "VG-03-A1", scenarios: {negative: true, adversarial: true, invariant: true}}, order: 37}
	"LS-03": {dependsOn: ["LS-02", "RN-03", "RN-05"], acceptance: {id: "LS-03-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 38}
	"RO-04": {dependsOn: ["RO-01", "PR-03", "PR-07", "RN-04", "RN-05"], acceptance: {id: "RO-04-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 39}
	"EV-02": {dependsOn: ["EV-01", "PR-02", "RO-01", "RO-04"], acceptance: {id: "EV-02-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 40}
	"LS-04": {dependsOn: ["LS-03"], acceptance: {id: "LS-04-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 41}
	"RN-06": {dependsOn: ["RN-04", "RN-05", "RO-04"], acceptance: {id: "RN-06-A1", scenarios: {positive: true, negative: true, adversarial: true, invariant: true}}, order: 42}
	"EV-03": {dependsOn: ["EV-02", "KR-04", "KR-05", "RN-04", "RN-06"], acceptance: {id: "EV-03-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 43}
	"FX-03": {dependsOn: ["RO-01", "EV-02"], acceptance: {id: "FX-03-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 44}
	"EV-05": {dependsOn: ["EV-03", "EV-04", "PR-06"], acceptance: {id: "EV-05-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 45}
	"EV-06": {dependsOn: ["EV-05", "PR-06", "RN-06"], acceptance: {id: "EV-06-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}}, order: 46}
	"FX-04": {dependsOn: ["PR-05", "EV-05"], acceptance: {id: "FX-04-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 47}
	"AR-01": {dependsOn: ["PK-01", "PR-07", "RO-01", "EV-06", "LS-04"], acceptance: {id: "AR-01-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 48}
	"VG-04": {dependsOn: ["VG-01", "VG-03", "EV-06"], acceptance: {id: "VG-04-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 49}
	"AR-02": {dependsOn: ["AR-01", "VG-04", "RN-06", "LS-04"], acceptance: {id: "AR-02-A1", scenarios: {positive: true, negative: true}}, order: 50}
	"FX-05": {dependsOn: ["FX-01", "FX-02", "FX-03", "FX-04", "FX-06", "RN-06", "EV-06", "VG-04"], acceptance: {id: "FX-05-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 51}
	"AR-03": {dependsOn: ["AR-02", "FX-05"], acceptance: {id: "AR-03-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 52}
	"AR-04": {dependsOn: ["AR-03", "PR-07", "RN-05"], acceptance: {id: "AR-04-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 53}
	"SK-05": {dependsOn: ["KR-05", "PK-04", "PR-06", "EV-06", "LS-04", "VG-04", "AR-04", "RN-06"], acceptance: {id: "SK-05-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 54}
	"RN-07": {dependsOn: ["RN-03", "SK-05"], acceptance: {id: "RN-07-A1", scenarios: {positive: true, negative: true, adversarial: true}}, order: 55}
	"SK-03": {dependsOn: ["SK-05", "RN-07"], acceptance: {id: "SK-03-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 56}
	"SK-04": {dependsOn: ["SK-03", "RN-07"], acceptance: {id: "SK-04-A1", scenarios: {positive: true, negative: true, invariant: true}}, order: 57}
})

selectedIDs: list.SortStrings([for id, _ in requirements {id}])
_closureProof: {
	for id, requirement in requirements {
		for dependency in requirement.dependsOn {
			"\(id)-depends-on-\(dependency)": list.Contains(selectedIDs, dependency) & true
		}
	}
}
_dagProof: {
	for id, requirement in requirements {
		for dependency in requirement.dependsOn {
			"\(dependency)-before-\(id)": (requirements[dependency].order < requirement.order) & true
		}
	}
}
_acceptanceProof: {
	for id, requirement in requirements {
		"\(id)-acceptance": requirement.acceptance.id & "\(id)-A1"
	}
}
closureComplete:    len(_closureProof) == 148
dagValid:           len(_dagProof) == 148
acceptanceComplete: len(requirements) == 58 && len(_acceptanceProof) == 58

unitSatisfaction: closureComplete && dagValid && acceptanceComplete
