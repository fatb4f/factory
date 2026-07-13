package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"runtime"
	"runtime/debug"
	"time"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
)

const (
	protocol          = "cue-workbook/v0"
	cueEngineRevision = "806821e40fae070318600a264d311517e596353b"
)

type Limits struct {
	TimeoutMS      int `json:"timeout_ms"`
	MaxOutputBytes int `json:"max_output_bytes"`
}

type Request struct {
	Protocol  string         `json:"protocol"`
	RequestID string         `json:"request_id"`
	Operation string         `json:"operation"`
	Payload   map[string]any `json:"payload"`
	Limits    Limits         `json:"limits"`
}

type Diagnostic struct {
	Phase      string `json:"phase"`
	Raw        string `json:"raw"`
	Message    string `json:"message"`
	Provenance string `json:"provenance"`
}

type Response struct {
	Protocol       string            `json:"protocol"`
	RequestID      string            `json:"request_id"`
	ExecutionState string            `json:"execution_state"`
	Backend        map[string]any    `json:"backend"`
	Stages         map[string]string `json:"stages"`
	Facts          map[string]any    `json:"facts"`
	Diagnostics    []Diagnostic      `json:"diagnostics"`
	Metrics        map[string]any    `json:"metrics"`
	Stderr         string            `json:"stderr"`
}

func main() {
	started := time.Now()
	reader := bufio.NewReader(os.Stdin)
	line, err := reader.ReadBytes('\n')
	if err != nil && len(line) == 0 {
		writeProtocolError("", "read request", err, started)
		return
	}

	var req Request
	if err := json.Unmarshal(line, &req); err != nil {
		writeProtocolError("", "decode request", err, started)
		return
	}
	if req.Protocol != protocol || req.RequestID == "" {
		writeProtocolError(
			req.RequestID,
			"validate envelope",
			errors.New("invalid protocol or request_id"),
			started,
		)
		return
	}

	resp := execute(req, started)
	enc := json.NewEncoder(os.Stdout)
	enc.SetEscapeHTML(false)
	if err := enc.Encode(resp); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
}

func execute(req Request, started time.Time) Response {
	resp := baseResponse(req.RequestID, started)
	ctx := cuecontext.New()

	compile := func(sourceKey, filenameKey string) (cue.Value, error) {
		source, ok := req.Payload[sourceKey].(string)
		if !ok {
			return cue.Value{}, fmt.Errorf("missing %s", sourceKey)
		}
		filename, _ := req.Payload[filenameKey].(string)
		if filename == "" {
			filename = sourceKey + ".cue"
		}
		value := ctx.CompileString(source, cue.Filename(filename))
		if err := value.Err(); err != nil {
			return value, err
		}
		return value, nil
	}

	lookup := func(value cue.Value, key string) (cue.Value, error) {
		pathString, ok := req.Payload[key].(string)
		if !ok || pathString == "" {
			return value, nil
		}
		path := cue.ParsePath(pathString)
		if err := path.Err(); err != nil {
			return cue.Value{}, err
		}
		found := value.LookupPath(path)
		if err := found.Err(); err != nil {
			return found, err
		}
		return found, nil
	}

	reject := func(phase string, err error) Response {
		resp.ExecutionState = "cue-rejection"
		resp.Stages[phase] = "rejected"
		resp.Diagnostics = append(resp.Diagnostics, Diagnostic{
			Phase: phase, Raw: err.Error(), Message: err.Error(), Provenance: "native",
		})
		return finish(resp, started)
	}

	switch req.Operation {
	case "compile":
		value, err := compile("source", "filename")
		if err != nil {
			return reject("compile", err)
		}
		resp.Stages["compile"] = "completed"
		resp.Facts["semantic_bottom"] = value.Err() != nil

	case "lookup":
		value, err := compile("source", "filename")
		if err != nil {
			return reject("compile", err)
		}
		resp.Stages["compile"] = "completed"
		value, err = lookup(value, "path")
		if err != nil {
			return reject("lookup", err)
		}
		resp.Stages["lookup"] = "completed"
		resp.Facts["semantic_bottom"] = value.Err() != nil

	case "unify":
		left, err := compile("left_source", "left_filename")
		if err != nil {
			return reject("compile-left", err)
		}
		left, err = lookup(left, "left_path")
		if err != nil {
			return reject("lookup-left", err)
		}
		right, err := compile("right_source", "right_filename")
		if err != nil {
			return reject("compile-right", err)
		}
		right, err = lookup(right, "right_path")
		if err != nil {
			return reject("lookup-right", err)
		}
		unified := left.Unify(right)
		resp.Stages["unify"] = "completed"
		if err := unified.Err(); err != nil {
			resp.ExecutionState = "cue-rejection"
			resp.Facts["semantic_bottom"] = true
			resp.Diagnostics = append(resp.Diagnostics, Diagnostic{
				Phase: "unify", Raw: err.Error(), Message: err.Error(), Provenance: "native",
			})
		} else {
			resp.Facts["semantic_bottom"] = false
		}

	case "validate":
		value, err := compile("source", "filename")
		if err != nil {
			return reject("compile", err)
		}
		opts := []cue.Option{}
		if optionBool(req.Payload, "concrete") {
			opts = append(opts, cue.Concrete(true))
		}
		if optionBool(req.Payload, "disallow_cycles") {
			opts = append(opts, cue.DisallowCycles(true))
		}
		if err := value.Validate(opts...); err != nil {
			return reject("validate", err)
		}
		resp.Stages["validate"] = "completed"
		resp.Facts["valid"] = true

	case "subsume":
		general, err := compile("general_source", "general_filename")
		if err != nil {
			return reject("compile-general", err)
		}
		general, err = lookup(general, "general_path")
		if err != nil {
			return reject("lookup-general", err)
		}
		specific, err := compile("specific_source", "specific_filename")
		if err != nil {
			return reject("compile-specific", err)
		}
		specific, err = lookup(specific, "specific_path")
		if err != nil {
			return reject("lookup-specific", err)
		}
		if err := general.Subsume(specific); err != nil {
			resp.ExecutionState = "cue-rejection"
			resp.Facts["subsumes"] = false
			resp.Diagnostics = append(resp.Diagnostics, Diagnostic{
				Phase: "subsume", Raw: err.Error(), Message: err.Error(), Provenance: "native",
			})
		} else {
			resp.Facts["subsumes"] = true
		}
		resp.Stages["subsume"] = "completed"

	case "project-json":
		value, err := compile("source", "filename")
		if err != nil {
			return reject("compile", err)
		}
		value, err = lookup(value, "path")
		if err != nil {
			return reject("lookup", err)
		}
		data, err := value.MarshalJSON()
		if err != nil {
			return reject("project-json", err)
		}
		resp.Stages["project-json"] = "completed"
		resp.Facts["projection_json"] = string(data)

	default:
		resp.ExecutionState = "unsupported"
		resp.Diagnostics = append(resp.Diagnostics, Diagnostic{
			Phase: "backend", Raw: "unsupported operation", Message: req.Operation,
			Provenance: "operation-boundary",
		})
	}

	return finish(resp, started)
}

func optionBool(payload map[string]any, name string) bool {
	options, ok := payload["options"].(map[string]any)
	if !ok {
		return false
	}
	value, _ := options[name].(bool)
	return value
}

func baseResponse(requestID string, started time.Time) Response {
	return Response{
		Protocol: protocol, RequestID: requestID, ExecutionState: "completed",
		Backend: map[string]any{
			"id":                 "go-runner",
			"go_version":         runtime.Version(),
			"cue_module_version": cueModuleVersion(),
			"engine_revision":    cueEngineRevision,
		},
		Stages: map[string]string{}, Facts: map[string]any{}, Diagnostics: []Diagnostic{},
		Metrics: map[string]any{"started_unix_ns": started.UnixNano()},
	}
}

func finish(resp Response, started time.Time) Response {
	resp.Metrics["duration_ms"] = float64(time.Since(started).Microseconds()) / 1000
	return resp
}

func writeProtocolError(requestID, phase string, err error, started time.Time) {
	resp := baseResponse(requestID, started)
	resp.ExecutionState = "protocol-error"
	resp.Diagnostics = append(resp.Diagnostics, Diagnostic{
		Phase: phase, Raw: err.Error(), Message: err.Error(), Provenance: "operation-boundary",
	})
	_ = json.NewEncoder(os.Stdout).Encode(finish(resp, started))
}

func cueModuleVersion() string {
	info, ok := debug.ReadBuildInfo()
	if !ok {
		return "unknown"
	}
	for _, dependency := range info.Deps {
		if dependency.Path == "cuelang.org/go" {
			return dependency.Version
		}
	}
	return "unknown"
}
