package probe

operations: {
	compile: {
		requiredPayload: ["source", "filename"]
	}
	lookup: {
		requiredPayload: ["source", "filename", "path"]
	}
	unify: {
		requiredPayload: ["leftSource", "leftPath", "rightSource", "rightPath"]
	}
	validate: {
		requiredPayload: ["source", "filename"]
	}
	subsume: {
		requiredPayload: ["generalSource", "generalPath", "specificSource", "specificPath"]
	}
	"project-json": {
		requiredPayload: ["source", "filename"]
	}
}
