set positional-arguments

workbook := "marimo/workflows/cue/cue_workbook.py"
fixture := "marimo/workflows/cue/fixtures/conformance.json"

cue-transaction request promotion_root:
    #!/usr/bin/env bash
    set -euo pipefail
    repo_root="{{ justfile_directory() }}"
    request_path="$(realpath "{{ request }}")"
    promotion_path="$(realpath -m "{{ promotion_root }}")"
    runtime_base="${XDG_RUNTIME_DIR:-/tmp}"
    transient_root="$(mktemp -d "${runtime_base}/factory-cue-105.XXXXXXXX")"
    dependency_root="$(mktemp -d "${runtime_base}/factory-cue-dependencies.XXXXXXXX")"
    environment_root="$(mktemp -d "${runtime_base}/factory-cue-python.XXXXXXXX")"
    cleanup() {
        rm -rf "$transient_root" "$dependency_root" "$environment_root"
    }
    trap cleanup EXIT
    cue_bin="$(command -v cue)"
    go_bin="$(command -v go)"
    uv_bin="$(command -v uv)"
    authority="$(UV_PROJECT_ENVIRONMENT="$environment_root" "$uv_bin" run --project "$repo_root" --locked --exact -- python "$repo_root/{{ workbook }}" --authority)"
    cue_py_repository="$(jq -r '.cuePy.repository' <<<"$authority")"
    cue_py_revision="$(jq -r '.cuePy.revision' <<<"$authority")"
    libcue_repository="$(jq -r '.libcue.repository' <<<"$authority")"
    libcue_revision="$(jq -r '.libcue.revision' <<<"$authority")"
    kernel_repository="$(jq -r '.kernel.repository' <<<"$authority")"
    kernel_revision="$(jq -r '.kernel.revision' <<<"$authority")"
    kernel_relative_path="$(jq -r '.kernel.relativePath' <<<"$authority")"
    git clone --quiet --no-checkout "$cue_py_repository" "$dependency_root/cue-py"
    git -C "$dependency_root/cue-py" checkout --quiet "$cue_py_revision"
    git clone --quiet --no-checkout "$libcue_repository" "$dependency_root/libcue"
    git -C "$dependency_root/libcue" checkout --quiet "$libcue_revision"
    git clone --quiet --no-checkout "$kernel_repository" "$dependency_root/lattice"
    git -C "$dependency_root/lattice" checkout --quiet "$kernel_revision"
    case "$(uname -s)" in
        Darwin) library_name="libcue.dylib" ;;
        MINGW*|MSYS*|CYGWIN*) library_name="cue.dll" ;;
        *) library_name="libcue.so" ;;
    esac
    (cd "$dependency_root/libcue" && "$go_bin" build -o "$library_name" -buildmode=c-shared)
    UV_PROJECT_ENVIRONMENT="$environment_root" "$uv_bin" run \
        --project "$repo_root" --locked --exact -- \
        python "$repo_root/{{ workbook }}" \
        --repo-root "$repo_root" \
        --transient-root "$transient_root" \
        --shadow-root "$transient_root/shadow" \
        --promotion-root "$promotion_path" \
        --request "$request_path" \
        --kernel-path "$dependency_root/lattice/$kernel_relative_path" \
        --cue-py-root "$dependency_root/cue-py" \
        --libcue-root "$dependency_root/libcue" \
        --libcue-library "$dependency_root/libcue/$library_name" \
        --cue-bin "$cue_bin" \
        --go-bin "$go_bin" \
        --uv-bin "$uv_bin"

validate-cue-emergency:
    #!/usr/bin/env bash
    set -euo pipefail
    repo_root="{{ justfile_directory() }}"
    runtime_base="${XDG_RUNTIME_DIR:-/tmp}"
    dependency_root="$(mktemp -d "${runtime_base}/factory-cue-validation.XXXXXXXX")"
    environment_root="$(mktemp -d "${runtime_base}/factory-cue-validation-python.XXXXXXXX")"
    cleanup() {
        rm -rf "$dependency_root" "$environment_root"
    }
    trap cleanup EXIT
    cue_bin="$(command -v cue)"
    uv_bin="$(command -v uv)"
    authority="$(UV_PROJECT_ENVIRONMENT="$environment_root" "$uv_bin" run --project "$repo_root" --locked --exact -- python "$repo_root/{{ workbook }}" --authority)"
    kernel_repository="$(jq -r '.kernel.repository' <<<"$authority")"
    kernel_revision="$(jq -r '.kernel.revision' <<<"$authority")"
    kernel_relative_path="$(jq -r '.kernel.relativePath' <<<"$authority")"
    git clone --quiet --no-checkout "$kernel_repository" "$dependency_root/lattice"
    git -C "$dependency_root/lattice" checkout --quiet "$kernel_revision"
    "$uv_bin" lock --check --project "$repo_root"
    UV_PROJECT_ENVIRONMENT="$environment_root" "$uv_bin" run \
        --project "$repo_root" --locked --exact -- \
        python "$repo_root/{{ workbook }}" \
        --self-test "$repo_root/{{ fixture }}" \
        --cue-bin "$cue_bin" \
        --kernel-path "$dependency_root/lattice/$kernel_relative_path"
