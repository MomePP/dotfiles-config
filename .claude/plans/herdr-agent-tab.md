# herdr-agent-tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A herdr plugin so `Ctrl-a n` opens a coding agent in a new tab of the *current* space, on the current checkout or on a fresh `.worktrees/<slug>` git worktree.

**Architecture:** One Go binary with two subcommands. `new` is the headless action a key binds to; it opens the plugin's popup pane. `picker` runs in that popup: `charmbracelet/huh` forms ask agent / where / branch, then `internal/app.Execute` drives git and the herdr CLI (`$HERDR_BIN_PATH`) through a `run.Runner` interface so tests and `--dry-run` swap in a recording fake.

**Tech Stack:** Go 1.24+ (1.27.1 installed), `github.com/charmbracelet/huh`, herdr 0.8.2 plugin API (`herdr-plugin.toml`, `plugin pane open`, `tab create`, `agent start`), git ≥ 2.31 (`--path-format=absolute`).

**Spec:** `/Users/momeppkt/.config/.claude/specs/herdr-agent-tab-design.md`

## Global Constraints

- Plugin id `momepp.agent-tab`; action id `new`; pane id `picker`; `min_herdr_version = "0.8.2"`; `platforms = ["macos", "linux"]`.
- Repo `~/Developer/herdr-plugins/herdr-agent-tab`, module `github.com/MomePP/herdr-agent-tab`, MIT.
- Worktrees at `<repo root>/.worktrees/<slug>`; never write to a tracked `.gitignore`, only `.git/info/exclude`.
- Agent names match `[a-z][a-z0-9_-]{0,31}` and are unique among live agents.
- Agent kinds come from `herdr agent start --help`, filtered by `PATH`; nothing hard-coded.
- Every runtime command goes through `run.Runner`; no direct `exec.Command` outside `internal/run`.
- Commit identity: `git -c user.email=13793017+MomePP@users.noreply.github.com` is already the global default; do not use the harness email.
- Dotfiles-side work happens on branch `feature/herdr-native-workflow` in `~/.config`. Plugin work happens in the plugin repo. Never run `herdr server stop` from inside a herdr pane.

---

## File map

```
~/Developer/herdr-plugins/herdr-agent-tab/
  herdr-plugin.toml            manifest: build, action `new`, popup pane `picker`
  go.mod / go.sum
  .gitignore                   bin/
  README.md                    install + keybinding (the only user-facing doc)
  cmd/agent-tab/main.go        subcommand dispatch; `new` (open popup / --dry-run); `picker` (popup flow)
  cmd/agent-tab/main_test.go   golden test for --dry-run
  internal/run/run.go          Runner interface; Exec (real); Fake (records, replies, optional echo); Canned replies
  internal/run/run_test.go
  internal/slug/slug.go        Slug(branch); AgentName(kind, slug, taken)
  internal/slug/slug_test.go
  internal/gitx/gitx.go        Repo: Open, CurrentBranch, FlowPrefix/FlowDevelop/HasFlow, BranchExists,
                               WorktreeDir, IsExcluded, AppendExclude, AddWorktree, RecordFlowBase
  internal/gitx/gitx_test.go   real git in t.TempDir()
  internal/herdr/herdr.go      Client: AgentKinds, Installed, Context, TabCreate, AgentStart, AgentNames, OpenPicker
  internal/herdr/herdr_test.go Fake runner
  internal/app/app.go          Request/Result/Deps; Execute; LastKind/SaveLastKind
  internal/app/app_test.go     real git + Fake herdr
  internal/picker/picker.go    huh forms: Run, Confirm, Pause (manual test only)
~/.config (feature/herdr-native-workflow)
  herdr/config.toml            drop herdr-plus bindings, add prefix+n → momepp.agent-tab.new
  .gitignore                   drop the herdr-plus carve-out
  herdr/plugins/config/cloudmanic.herdr-plus/   delete
  .claude/knowledges/herdr-keymap.md            n = new agent tab here
```

---

### Task 1: Scaffold the repo, manifest, and a linkable binary

**Files:**
- Create: `herdr-plugin.toml`, `go.mod`, `.gitignore`, `README.md`, `cmd/agent-tab/main.go`

**Interfaces:**
- Produces: `main` dispatching `new` and `picker` (both stubs that print "not implemented" and exit 1). Tasks 8 replaces the stubs.

- [ ] **Step 1: Create the module**

```bash
mkdir -p ~/Developer/herdr-plugins/herdr-agent-tab && cd ~/Developer/herdr-plugins/herdr-agent-tab
git init -b main
go mod init github.com/MomePP/herdr-agent-tab
go get github.com/charmbracelet/huh@latest
```

- [ ] **Step 2: Write the manifest**

`herdr-plugin.toml`:
```toml
id = "momepp.agent-tab"
name = "Agent Tab"
version = "0.1.0"
min_herdr_version = "0.8.2"
description = "Open an agent in a new tab of this space, on the checkout or a fresh worktree"
platforms = ["macos", "linux"]

[[build]]
command = ["go", "build", "-o", "bin/agent-tab", "./cmd/agent-tab"]

[[actions]]
id = "new"
title = "New agent tab here"
contexts = ["workspace", "pane"]
command = ["./bin/agent-tab", "new"]

[[panes]]
id = "picker"
title = "New agent tab"
placement = "popup"
width = "70%"
height = 16
command = ["./bin/agent-tab", "picker"]
```

- [ ] **Step 3: Write `.gitignore` and `README.md`**

`.gitignore`:
```
bin/
```

`README.md`:
````markdown
# herdr-agent-tab

Open a coding agent in a **new tab of the current herdr space**, on the current
checkout or on a fresh git worktree under `<repo>/.worktrees/<slug>`.
herdr's own worktree flow makes a new *space* per worktree; this keeps
space = project, tab = agent.

Requires herdr 0.8.2+ and Go 1.24+ (herdr builds the plugin on install).

```sh
herdr plugin install MomePP/herdr-agent-tab
```

Bind a key in `~/.config/herdr/config.toml`, then `herdr server reload-config`:

```toml
[[keys.command]]
key = "prefix+n"
type = "plugin_action"
command = "momepp.agent-tab.new"
description = "new agent tab here"
```

The popup asks for the agent (every kind herdr supports that is on your
`PATH`), local checkout or new worktree, and the branch name. Branch prefix and
base come from the repo's git-flow config when present, else the current branch.
If `.worktrees/` is not ignored the plugin adds it to `.git/info/exclude`.

Dry run from a shell: `agent-tab new --dry-run --agent claude --where worktree --branch feature/x`.
````

- [ ] **Step 4: Write the stub main**

`cmd/agent-tab/main.go`:
```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}
	var err error
	switch os.Args[1] {
	case "new", "picker":
		err = fmt.Errorf("%s: not implemented", os.Args[1])
	default:
		usage()
		os.Exit(2)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "agent-tab:", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: agent-tab new [--dry-run --agent K --where local|worktree --branch B] | agent-tab picker")
}
```

- [ ] **Step 5: Build and link**

```bash
go build -o bin/agent-tab ./cmd/agent-tab && ./bin/agent-tab new; echo "exit=$?"
herdr plugin link "$PWD"
herdr plugin action list --plugin momepp.agent-tab
```
Expected: `agent-tab: new: not implemented`, `exit=1`; the action list shows `new`.

- [ ] **Step 6: Commit**

```bash
git add -A && git commit -m "chore: scaffold herdr-agent-tab plugin with manifest and stub binary"
```

---

### Task 2: `internal/run` — the Runner boundary

**Files:**
- Create: `internal/run/run.go`, `internal/run/run_test.go`

**Interfaces:**
- Produces:
  - `type Runner interface { Run(dir, name string, args ...string) ([]byte, error) }`
  - `type Exec struct{}` — real processes; on failure the error text is stderr.
  - `type Fake struct { Calls [][]string; Reply func(name string, args []string) ([]byte, error); Print io.Writer }`
  - `func Canned(cwd, branch string) func(name string, args []string) ([]byte, error)` — replies for the read-only commands the flow needs.

- [ ] **Step 1: Failing tests**

`internal/run/run_test.go`:
```go
package run

import (
	"bytes"
	"strings"
	"testing"
)

func TestFakeRecordsAndEchoes(t *testing.T) {
	var out bytes.Buffer
	f := &Fake{Print: &out, Reply: func(name string, args []string) ([]byte, error) {
		return []byte("ok"), nil
	}}
	got, err := f.Run("/tmp", "git", "status", "--short")
	if err != nil || string(got) != "ok" {
		t.Fatalf("got %q, %v", got, err)
	}
	if len(f.Calls) != 1 || strings.Join(f.Calls[0], " ") != "git status --short" {
		t.Fatalf("calls = %v", f.Calls)
	}
	if out.String() != "$ git status --short\n" {
		t.Fatalf("echo = %q", out.String())
	}
}

func TestExecReturnsStderrOnFailure(t *testing.T) {
	_, err := Exec{}.Run("", "sh", "-c", "echo boom >&2; exit 3")
	if err == nil || !strings.Contains(err.Error(), "boom") {
		t.Fatalf("err = %v", err)
	}
}

func TestCannedAnswersTheFlow(t *testing.T) {
	reply := Canned("/repo", "develop")
	out, _ := reply("git", []string{"rev-parse", "--path-format=absolute", "--git-common-dir"})
	if strings.TrimSpace(string(out)) != "/repo/.git" {
		t.Fatalf("common dir = %q", out)
	}
	out, _ = reply("herdr", []string{"tab", "create", "--workspace", "w", "--cwd", "/x", "--label", "l", "--focus"})
	if !strings.Contains(string(out), `"pane_id"`) {
		t.Fatalf("tab create reply = %q", out)
	}
	if _, err := reply("git", []string{"check-ignore", "-q", ".worktrees"}); err == nil {
		t.Fatal("check-ignore should report not ignored")
	}
}
```

- [ ] **Step 2: Run, expect compile failure**

Run: `go test ./internal/run/`
Expected: FAIL — `undefined: Fake`, `Exec`, `Canned`.

- [ ] **Step 3: Implement**

`internal/run/run.go`:
```go
// Package run is the only place that starts processes. Everything else takes
// a Runner so tests and dry runs can record and replay instead.
package run

import (
	"bytes"
	"fmt"
	"io"
	"os/exec"
	"strings"
)

// Runner executes name with args in dir and returns its stdout.
type Runner interface {
	Run(dir, name string, args ...string) ([]byte, error)
}

// Exec runs real processes. A non-zero exit becomes an error carrying stderr.
type Exec struct{}

func (Exec) Run(dir, name string, args ...string) ([]byte, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	var stdout, stderr bytes.Buffer
	cmd.Stdout, cmd.Stderr = &stdout, &stderr
	if err := cmd.Run(); err != nil {
		msg := strings.TrimSpace(stderr.String())
		if msg == "" {
			msg = err.Error()
		}
		return stdout.Bytes(), fmt.Errorf("%s %s: %s", name, strings.Join(args, " "), msg)
	}
	return stdout.Bytes(), nil
}

// Fake records every call, answers from Reply, and echoes "$ name args" to
// Print when set. Tests assert on Calls; --dry-run shows Print to the user.
type Fake struct {
	Calls [][]string
	Reply func(name string, args []string) ([]byte, error)
	Print io.Writer
}

func (f *Fake) Run(dir, name string, args ...string) ([]byte, error) {
	call := append([]string{name}, args...)
	f.Calls = append(f.Calls, call)
	if f.Print != nil {
		fmt.Fprintf(f.Print, "$ %s\n", strings.Join(call, " "))
	}
	if f.Reply == nil {
		return nil, nil
	}
	return f.Reply(name, args)
}

// Canned answers the read-only git and herdr commands app.Execute issues, so a
// dry run walks the whole flow without a repo or a herdr server. The repo is
// rooted at cwd on branch, has no git-flow config, no existing branches, and
// .worktrees is not yet ignored.
func Canned(cwd, branch string) func(name string, args []string) ([]byte, error) {
	return func(name string, args []string) ([]byte, error) {
		joined := strings.Join(args, " ")
		switch {
		case name == "git" && joined == "rev-parse --path-format=absolute --git-common-dir":
			return []byte(cwd + "/.git\n"), nil
		case name == "git" && joined == "rev-parse --abbrev-ref HEAD":
			return []byte(branch + "\n"), nil
		case name == "git" && strings.HasPrefix(joined, "config --get "):
			return nil, fmt.Errorf("git %s: not set", joined)
		case name == "git" && strings.HasPrefix(joined, "rev-parse --verify"):
			return nil, fmt.Errorf("git %s: no such ref", joined)
		case name == "git" && strings.HasPrefix(joined, "check-ignore"):
			return nil, fmt.Errorf("git %s: not ignored", joined)
		case strings.HasPrefix(joined, "tab create"):
			return []byte(`{"result":{"tab":{"tab_id":"wD:t9"},"root_pane":{"pane_id":"wD:p9"}}}`), nil
		case strings.HasPrefix(joined, "agent list"):
			return []byte(`{"result":{"agents":[]}}`), nil
		}
		return nil, nil
	}
}
```

- [ ] **Step 4: Run, expect pass**

Run: `go test ./internal/run/`
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add internal/run && git commit -m "feat(run): Runner boundary with Exec, recording Fake, and canned replies"
```

---

### Task 3: `internal/slug` — slugs and agent names

**Files:**
- Create: `internal/slug/slug.go`, `internal/slug/slug_test.go`

**Interfaces:**
- Produces: `func Slug(branch string) string`, `func AgentName(kind, slug string, taken []string) string`

- [ ] **Step 1: Failing tests**

`internal/slug/slug_test.go`:
```go
package slug

import "testing"

func TestSlug(t *testing.T) {
	cases := map[string]string{
		"feature/shuttle-types":  "feature-shuttle-types",
		"Feature/Shuttle Types":  "feature-shuttle-types",
		"bugfix//double":         "bugfix-double",
		"/leading/and/trailing/": "leading-and-trailing",
		"weird!!chars$$here":     "weird-chars-here",
		"under_score":            "under_score",
	}
	for in, want := range cases {
		if got := Slug(in); got != want {
			t.Errorf("Slug(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestAgentName(t *testing.T) {
	if got := AgentName("claude", "feature-x", nil); got != "claude-feature-x" {
		t.Fatalf("got %q", got)
	}
	if got := AgentName("claude", "", nil); got != "claude" {
		t.Fatalf("empty slug: got %q", got)
	}
	long := AgentName("opencode", "a-very-long-branch-name-that-keeps-going-on", nil)
	if len(long) > 32 || long[len(long)-1] == '-' {
		t.Fatalf("not capped cleanly: %q (%d)", long, len(long))
	}
	got := AgentName("claude", "feature-x", []string{"claude-feature-x", "claude-feature-x-2"})
	if got != "claude-feature-x-3" {
		t.Fatalf("unique: got %q", got)
	}
	capped := AgentName("opencode", "a-very-long-branch-name-that-keeps-going-on",
		[]string{"opencode-a-very-long-branch-name"})
	if len(capped) > 32 || capped == "opencode-a-very-long-branch-name" {
		t.Fatalf("unique+capped: got %q (%d)", capped, len(capped))
	}
}
```

- [ ] **Step 2: Run, expect compile failure**

Run: `go test ./internal/slug/`
Expected: FAIL — `undefined: Slug`, `AgentName`.

- [ ] **Step 3: Implement**

`internal/slug/slug.go`:
```go
// Package slug derives directory names, tab labels, and herdr agent names
// from branch names.
package slug

import (
	"fmt"
	"regexp"
	"strings"
)

var (
	junk   = regexp.MustCompile(`[^a-z0-9_-]+`)
	dashes = regexp.MustCompile(`-{2,}`)
)

// Slug lower-cases branch, turns "/" and anything outside [a-z0-9_-] into "-",
// collapses runs, and trims the ends: "Feature/Shuttle Types" -> "feature-shuttle-types".
func Slug(branch string) string {
	s := strings.ToLower(strings.ReplaceAll(branch, "/", "-"))
	s = junk.ReplaceAllString(s, "-")
	s = dashes.ReplaceAllString(s, "-")
	return strings.Trim(s, "-")
}

// maxName is herdr's agent-name limit: [a-z][a-z0-9_-]{0,31}.
const maxName = 32

// AgentName builds "<kind>-<slug>" (or just kind when slug is empty), capped at
// maxName without a trailing "-", and made unique against taken with -2, -3, ….
func AgentName(kind, slug string, taken []string) string {
	base := kind
	if slug != "" {
		base = kind + "-" + slug
	}
	base = cap(base, maxName)
	if !contains(taken, base) {
		return base
	}
	for i := 2; ; i++ {
		suffix := fmt.Sprintf("-%d", i)
		cand := cap(base, maxName-len(suffix)) + suffix
		if !contains(taken, cand) {
			return cand
		}
	}
}

func cap(s string, n int) string {
	if len(s) > n {
		s = s[:n]
	}
	return strings.TrimRight(s, "-")
}

func contains(list []string, s string) bool {
	for _, v := range list {
		if v == s {
			return true
		}
	}
	return false
}
```

- [ ] **Step 4: Run, expect pass**

Run: `go test ./internal/slug/`
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add internal/slug && git commit -m "feat(slug): branch slugs and unique capped agent names"
```

---

### Task 4: `internal/gitx` — repo facts and worktree creation

**Files:**
- Create: `internal/gitx/gitx.go`, `internal/gitx/gitx_test.go`

**Interfaces:**
- Consumes: `run.Runner`
- Produces:
  - `type Repo struct { Root, Common, Dir string; R run.Runner }`
  - `var ErrNotRepo error`
  - `func Open(r run.Runner, dir string) (*Repo, error)` — Root is the *main* checkout even when dir is inside a linked worktree.
  - `func (r *Repo) CurrentBranch() (string, error)`
  - `func (r *Repo) FlowPrefix() string`, `FlowDevelop() string`, `HasFlow() bool`
  - `func (r *Repo) BranchExists(name string) bool`
  - `func (r *Repo) WorktreeDir(slug string) string`
  - `func (r *Repo) IsExcluded() bool`, `func (r *Repo) AppendExclude() error`
  - `func (r *Repo) AddWorktree(dir, branch, base string, newBranch bool) error`
  - `func (r *Repo) RecordFlowBase(branch, base string) error`

- [ ] **Step 1: Failing tests**

`internal/gitx/gitx_test.go`:
```go
package gitx

import (
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/MomePP/herdr-agent-tab/internal/run"
)

// initRepo makes a repo on branch main with one commit and returns its path.
func initRepo(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	dir, _ = filepath.EvalSymlinks(dir) // macOS /var -> /private/var
	x := run.Exec{}
	for _, args := range [][]string{
		{"init", "-b", "main"},
		{"config", "user.email", "t@example.com"},
		{"config", "user.name", "t"},
		{"commit", "--allow-empty", "-m", "init"},
	} {
		if _, err := x.Run(dir, "git", args...); err != nil {
			t.Fatal(err)
		}
	}
	return dir
}

func TestOpenNotRepo(t *testing.T) {
	_, err := Open(run.Exec{}, t.TempDir())
	if !errors.Is(err, ErrNotRepo) {
		t.Fatalf("err = %v", err)
	}
}

func TestOpenAndBranch(t *testing.T) {
	dir := initRepo(t)
	r, err := Open(run.Exec{}, dir)
	if err != nil {
		t.Fatal(err)
	}
	if r.Root != dir {
		t.Fatalf("Root = %q, want %q", r.Root, dir)
	}
	if b, _ := r.CurrentBranch(); b != "main" {
		t.Fatalf("branch = %q", b)
	}
	if r.WorktreeDir("feature-x") != filepath.Join(dir, ".worktrees", "feature-x") {
		t.Fatalf("WorktreeDir = %q", r.WorktreeDir("feature-x"))
	}
}

func TestFlowConfig(t *testing.T) {
	dir := initRepo(t)
	r, _ := Open(run.Exec{}, dir)
	if r.HasFlow() || r.FlowPrefix() != "" {
		t.Fatal("no git-flow expected yet")
	}
	x := run.Exec{}
	x.Run(dir, "git", "config", "gitflow.prefix.feature", "feature/")
	x.Run(dir, "git", "config", "gitflow.branch.develop", "develop")
	if !r.HasFlow() || r.FlowPrefix() != "feature/" || r.FlowDevelop() != "develop" {
		t.Fatalf("flow: prefix=%q develop=%q", r.FlowPrefix(), r.FlowDevelop())
	}
	if err := r.RecordFlowBase("feature/x", "develop"); err != nil {
		t.Fatal(err)
	}
	out, _ := x.Run(dir, "git", "config", "--get", "gitflow.branch.feature/x.base")
	if strings.TrimSpace(string(out)) != "develop" {
		t.Fatalf("recorded base = %q", out)
	}
}

func TestExclude(t *testing.T) {
	dir := initRepo(t)
	r, _ := Open(run.Exec{}, dir)
	if r.IsExcluded() {
		t.Fatal(".worktrees should not be ignored yet")
	}
	if err := r.AppendExclude(); err != nil {
		t.Fatal(err)
	}
	if !r.IsExcluded() {
		t.Fatal(".worktrees should be ignored after AppendExclude")
	}
	b, _ := os.ReadFile(filepath.Join(dir, ".git", "info", "exclude"))
	if !strings.Contains(string(b), ".worktrees/") {
		t.Fatalf("exclude = %q", b)
	}
	if _, err := os.Stat(filepath.Join(dir, ".gitignore")); err == nil {
		t.Fatal(".gitignore must not be created")
	}
}

func TestAddWorktree(t *testing.T) {
	dir := initRepo(t)
	r, _ := Open(run.Exec{}, dir)
	wt := r.WorktreeDir("feature-x")
	if r.BranchExists("feature/x") {
		t.Fatal("branch should not exist yet")
	}
	if err := r.AddWorktree(wt, "feature/x", "main", true); err != nil {
		t.Fatal(err)
	}
	if !r.BranchExists("feature/x") {
		t.Fatal("branch should exist after AddWorktree")
	}
	inner, err := Open(run.Exec{}, wt)
	if err != nil {
		t.Fatal(err)
	}
	if inner.Root != dir {
		t.Fatalf("Root from inside a worktree = %q, want main checkout %q", inner.Root, dir)
	}
	if b, _ := inner.CurrentBranch(); b != "feature/x" {
		t.Fatalf("worktree branch = %q", b)
	}
	// existing branch, no -b
	run.Exec{}.Run(dir, "git", "branch", "feature/y")
	if err := r.AddWorktree(r.WorktreeDir("feature-y"), "feature/y", "", false); err != nil {
		t.Fatal(err)
	}
}
```

- [ ] **Step 2: Run, expect compile failure**

Run: `go test ./internal/gitx/`
Expected: FAIL — undefined `Open`, `ErrNotRepo`, …

- [ ] **Step 3: Implement**

`internal/gitx/gitx.go`:
```go
// Package gitx answers the git questions the flow needs and creates worktrees.
package gitx

import (
	"errors"
	"os"
	"path/filepath"
	"strings"

	"github.com/MomePP/herdr-agent-tab/internal/run"
)

// ErrNotRepo means dir is not inside a git working tree.
var ErrNotRepo = errors.New("not a git repository")

// Repo is a checkout. Root is the main working tree (worktrees are created
// under it even when Dir is inside a linked worktree); Dir is where commands
// run, so branch and config answers follow the user's actual location.
type Repo struct {
	Root   string
	Common string // the shared .git directory
	Dir    string
	R      run.Runner
}

// Open resolves dir to its repository. Using --git-common-dir rather than
// --show-toplevel keeps .worktrees/ from nesting inside other worktrees.
func Open(r run.Runner, dir string) (*Repo, error) {
	out, err := r.Run(dir, "git", "rev-parse", "--path-format=absolute", "--git-common-dir")
	if err != nil {
		return nil, ErrNotRepo
	}
	common := strings.TrimSpace(string(out))
	if common == "" {
		return nil, ErrNotRepo
	}
	return &Repo{Root: filepath.Dir(common), Common: common, Dir: dir, R: r}, nil
}

func (r *Repo) git(args ...string) (string, error) {
	out, err := r.R.Run(r.Dir, "git", args...)
	return strings.TrimSpace(string(out)), err
}

func (r *Repo) CurrentBranch() (string, error) {
	return r.git("rev-parse", "--abbrev-ref", "HEAD")
}

func (r *Repo) config(key string) string {
	v, err := r.git("config", "--get", key)
	if err != nil {
		return ""
	}
	return v
}

// FlowPrefix is git-flow's feature prefix ("feature/") or "" without git-flow.
func (r *Repo) FlowPrefix() string { return r.config("gitflow.prefix.feature") }

// FlowDevelop is git-flow's develop branch or "" without git-flow.
func (r *Repo) FlowDevelop() string { return r.config("gitflow.branch.develop") }

func (r *Repo) HasFlow() bool { return r.FlowDevelop() != "" }

func (r *Repo) BranchExists(name string) bool {
	_, err := r.git("rev-parse", "--verify", "--quiet", "refs/heads/"+name)
	return err == nil
}

func (r *Repo) WorktreeDir(slug string) string {
	return filepath.Join(r.Root, ".worktrees", slug)
}

// IsExcluded reports whether .worktrees is already ignored by any rule.
func (r *Repo) IsExcluded() bool {
	_, err := r.git("check-ignore", "-q", ".worktrees")
	return err == nil
}

// AppendExclude ignores .worktrees/ via .git/info/exclude, which is local to
// the clone and never shows up in a diff.
func (r *Repo) AppendExclude() error {
	p := filepath.Join(r.Common, "info", "exclude")
	if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
		return err
	}
	f, err := os.OpenFile(p, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = f.WriteString("\n# added by herdr-agent-tab\n.worktrees/\n")
	return err
}

// AddWorktree checks branch out at dir. With newBranch it creates branch from
// base; otherwise base is ignored and the existing branch is used.
func (r *Repo) AddWorktree(dir, branch, base string, newBranch bool) error {
	args := []string{"worktree", "add"}
	if newBranch {
		args = append(args, "-b", branch, dir, base)
	} else {
		args = append(args, dir, branch)
	}
	_, err := r.git(args...)
	return err
}

// RecordFlowBase mirrors what `git flow feature start` stores.
func (r *Repo) RecordFlowBase(branch, base string) error {
	_, err := r.git("config", "gitflow.branch."+branch+".base", base)
	return err
}
```

- [ ] **Step 4: Run, expect pass**

Run: `go test ./internal/gitx/`
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add internal/gitx && git commit -m "feat(gitx): repo facts, git-flow config, exclude, and worktree add"
```

---

### Task 5: `internal/herdr` — CLI client

**Files:**
- Create: `internal/herdr/herdr.go`, `internal/herdr/herdr_test.go`

**Interfaces:**
- Consumes: `run.Runner`
- Produces:
  - `type Client struct { Bin string; R run.Runner }`
  - `func New(r run.Runner) *Client` — Bin from `HERDR_BIN_PATH`, else `"herdr"`
  - `func NewWith(bin string, r run.Runner) *Client`
  - `func (c *Client) AgentKinds() ([]string, error)`; `func ParseKinds(help string) []string`
  - `func Installed(kinds []string) []string`
  - `type Context struct { Cwd, WorkspaceID string }`; `func (c *Client) Context() (Context, error)`; `func ParseContext(raw string) Context`
  - `func (c *Client) TabCreate(workspace, cwd, label string) (paneID string, err error)`
  - `func (c *Client) AgentStart(name, kind, paneID string) error`
  - `func (c *Client) AgentNames() []string`
  - `func (c *Client) OpenPicker(plugin string) error`

- [ ] **Step 1: Failing tests**

`internal/herdr/herdr_test.go`:
```go
package herdr

import (
	"errors"
	"strings"
	"testing"

	"github.com/MomePP/herdr-agent-tab/internal/run"
)

const help = `Start a supported interactive agent in an existing pane
Options:
      --kind <KIND>
          Supported agent kind and canonical executable
          [possible values: pi, claude, codex, omp, opencode]
      --pane <ID>`

func TestParseKinds(t *testing.T) {
	got := ParseKinds(help)
	if strings.Join(got, ",") != "pi,claude,codex,omp,opencode" {
		t.Fatalf("got %v", got)
	}
	if ParseKinds("no list here") != nil {
		t.Fatal("expected nil without a marker")
	}
}

func TestInstalledFiltersByPath(t *testing.T) {
	got := Installed([]string{"sh", "definitely-not-a-real-agent-xyz"})
	if strings.Join(got, ",") != "sh" {
		t.Fatalf("got %v", got)
	}
}

func TestParseContext(t *testing.T) {
	ctx := ParseContext(`{"workspace":{"id":"wB"},"pane":{"pane_id":"wB:p3","cwd":"/repo"}}`)
	if ctx.Cwd != "/repo" || ctx.WorkspaceID != "wB" {
		t.Fatalf("plugin context: %+v", ctx)
	}
	ctx = ParseContext(`{"result":{"pane":{"cwd":"/x","foreground_cwd":"/x/sub","workspace_id":"wC"}}}`)
	if ctx.Cwd != "/x/sub" || ctx.WorkspaceID != "wC" {
		t.Fatalf("pane current: %+v", ctx)
	}
	if ParseContext("") != (Context{}) || ParseContext("not json") != (Context{}) {
		t.Fatal("garbage should yield an empty context")
	}
}

func TestContextFallsBackToPaneCurrent(t *testing.T) {
	t.Setenv("HERDR_PLUGIN_CONTEXT_JSON", "")
	t.Setenv("HERDR_WORKSPACE_ID", "")
	f := &run.Fake{Reply: func(name string, args []string) ([]byte, error) {
		return []byte(`{"result":{"pane":{"cwd":"/fallback","workspace_id":"wF"}}}`), nil
	}}
	ctx, err := NewWith("herdr", f).Context()
	if err != nil || ctx.Cwd != "/fallback" || ctx.WorkspaceID != "wF" {
		t.Fatalf("ctx=%+v err=%v", ctx, err)
	}
	if strings.Join(f.Calls[0], " ") != "herdr pane current" {
		t.Fatalf("calls = %v", f.Calls)
	}
}

func TestTabCreateAndAgentStart(t *testing.T) {
	f := &run.Fake{Reply: run.Canned("/repo", "main")}
	c := NewWith("herdr", f)
	id, err := c.TabCreate("wB", "/repo/.worktrees/x", "x")
	if err != nil || id != "wD:p9" {
		t.Fatalf("id=%q err=%v", id, err)
	}
	want := "herdr tab create --workspace wB --cwd /repo/.worktrees/x --label x --focus"
	if got := strings.Join(f.Calls[0], " "); got != want {
		t.Fatalf("argv = %q", got)
	}
	if err := c.AgentStart("claude-x", "claude", id); err != nil {
		t.Fatal(err)
	}
	want = "herdr agent start claude-x --kind claude --pane wD:p9"
	if got := strings.Join(f.Calls[1], " "); got != want {
		t.Fatalf("argv = %q", got)
	}
}

func TestTabCreateRejectsReplyWithoutPane(t *testing.T) {
	f := &run.Fake{Reply: func(string, []string) ([]byte, error) { return []byte(`{"result":{}}`), nil }}
	_, err := NewWith("herdr", f).TabCreate("w", "/", "l")
	if err == nil || !strings.Contains(err.Error(), "root_pane") {
		t.Fatalf("err = %v", err)
	}
}

func TestAgentNames(t *testing.T) {
	f := &run.Fake{Reply: func(string, []string) ([]byte, error) {
		return []byte(`{"result":{"agents":[{"name":"claude-a","kind":"claude"},{"name":"omp-b"}]}}`), nil
	}}
	got := NewWith("herdr", f).AgentNames()
	if strings.Join(got, ",") != "claude-a,omp-b" {
		t.Fatalf("got %v", got)
	}
	bad := &run.Fake{Reply: func(string, []string) ([]byte, error) { return nil, errors.New("down") }}
	if NewWith("herdr", bad).AgentNames() != nil {
		t.Fatal("errors should yield nil, not fail the flow")
	}
}

func TestOpenPicker(t *testing.T) {
	f := &run.Fake{}
	if err := NewWith("herdr", f).OpenPicker("momepp.agent-tab"); err != nil {
		t.Fatal(err)
	}
	want := "herdr plugin pane open --plugin momepp.agent-tab --entrypoint picker"
	if got := strings.Join(f.Calls[0], " "); got != want {
		t.Fatalf("argv = %q", got)
	}
}
```

- [ ] **Step 2: Run, expect compile failure**

Run: `go test ./internal/herdr/`
Expected: FAIL — undefined symbols.

- [ ] **Step 3: Implement**

`internal/herdr/herdr.go`:
```go
// Package herdr drives the herdr CLI. Plugins get HERDR_BIN_PATH so calls
// work the same over the Unix socket and the Windows named pipe.
package herdr

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/MomePP/herdr-agent-tab/internal/run"
)

type Client struct {
	Bin string
	R   run.Runner
}

func New(r run.Runner) *Client {
	bin := os.Getenv("HERDR_BIN_PATH")
	if bin == "" {
		bin = "herdr"
	}
	return NewWith(bin, r)
}

func NewWith(bin string, r run.Runner) *Client { return &Client{Bin: bin, R: r} }

func (c *Client) run(args ...string) ([]byte, error) { return c.R.Run("", c.Bin, args...) }

// AgentKinds returns every kind herdr can start, read from its own --help so
// new kinds need no plugin release.
func (c *Client) AgentKinds() ([]string, error) {
	out, err := c.run("agent", "start", "--help")
	kinds := ParseKinds(string(out))
	if kinds == nil {
		if err != nil {
			return nil, err
		}
		return nil, errors.New("could not read agent kinds from `herdr agent start --help`")
	}
	return kinds, nil
}

// ParseKinds extracts "[possible values: a, b, c]" from clap-style help text.
func ParseKinds(help string) []string {
	const marker = "[possible values:"
	i := strings.Index(help, marker)
	if i < 0 {
		return nil
	}
	rest := help[i+len(marker):]
	j := strings.Index(rest, "]")
	if j < 0 {
		return nil
	}
	var kinds []string
	for _, k := range strings.Split(rest[:j], ",") {
		if k = strings.TrimSpace(k); k != "" {
			kinds = append(kinds, k)
		}
	}
	return kinds
}

// Installed keeps the kinds whose executable is on PATH. herdr's kind names are
// the canonical executables, so no mapping table is needed.
func Installed(kinds []string) []string {
	var out []string
	for _, k := range kinds {
		if _, err := exec.LookPath(k); err == nil {
			out = append(out, k)
		}
	}
	return out
}

// Context is where the user invoked the plugin.
type Context struct {
	Cwd         string
	WorkspaceID string
}

// Context reads HERDR_PLUGIN_CONTEXT_JSON and HERDR_WORKSPACE_ID first — a
// popup gets no HERDR_PANE_ID — and fills gaps from `pane current`.
func (c *Client) Context() (Context, error) {
	ctx := ParseContext(os.Getenv("HERDR_PLUGIN_CONTEXT_JSON"))
	if ctx.WorkspaceID == "" {
		ctx.WorkspaceID = os.Getenv("HERDR_WORKSPACE_ID")
	}
	if ctx.Cwd == "" || ctx.WorkspaceID == "" {
		if out, err := c.run("pane", "current"); err == nil {
			fb := ParseContext(string(out))
			if ctx.Cwd == "" {
				ctx.Cwd = fb.Cwd
			}
			if ctx.WorkspaceID == "" {
				ctx.WorkspaceID = fb.WorkspaceID
			}
		}
	}
	if ctx.Cwd == "" {
		return ctx, errors.New("could not resolve the focused pane's directory")
	}
	if ctx.WorkspaceID == "" {
		return ctx, errors.New("could not resolve the current workspace")
	}
	return ctx, nil
}

// ParseContext pulls cwd and workspace id out of either the plugin context
// JSON or a `pane current` reply. It looks inside a "pane" object first so a
// workspace-level cwd never shadows the pane's; foreground_cwd wins over cwd.
func ParseContext(raw string) Context {
	var v any
	if json.Unmarshal([]byte(raw), &v) != nil {
		return Context{}
	}
	scope := v
	if p := find(v, "pane"); p != nil {
		scope = p
	}
	ctx := Context{
		Cwd:         findString(scope, "foreground_cwd", "cwd"),
		WorkspaceID: findString(v, "workspace_id"),
	}
	if ctx.WorkspaceID == "" {
		if ws := find(v, "workspace"); ws != nil {
			ctx.WorkspaceID = findString(ws, "id", "workspace_id")
		}
	}
	return ctx
}

// TabCreate opens a focused tab in workspace at cwd and returns its root pane id.
func (c *Client) TabCreate(workspace, cwd, label string) (string, error) {
	out, err := c.run("tab", "create", "--workspace", workspace, "--cwd", cwd, "--label", label, "--focus")
	if err != nil {
		return "", err
	}
	var v any
	if err := json.Unmarshal(out, &v); err != nil {
		return "", fmt.Errorf("tab create: unreadable reply: %w", err)
	}
	id := findString(find(v, "root_pane"), "pane_id")
	if id == "" {
		return "", errors.New("tab create: no root_pane.pane_id in reply")
	}
	return id, nil
}

func (c *Client) AgentStart(name, kind, paneID string) error {
	_, err := c.run("agent", "start", name, "--kind", kind, "--pane", paneID)
	return err
}

// AgentNames lists live agent names for uniqueness. Errors yield nil: a
// missing list only risks a name clash, which herdr reports anyway.
func (c *Client) AgentNames() []string {
	out, err := c.run("agent", "list")
	if err != nil {
		return nil
	}
	var v any
	if json.Unmarshal(out, &v) != nil {
		return nil
	}
	return collectStrings(v, "name")
}

func (c *Client) OpenPicker(plugin string) error {
	_, err := c.run("plugin", "pane", "open", "--plugin", plugin, "--entrypoint", "picker")
	return err
}

// find returns the first value stored under key anywhere in v (depth-first).
func find(v any, key string) any {
	switch t := v.(type) {
	case map[string]any:
		if x, ok := t[key]; ok {
			return x
		}
		for _, child := range t {
			if x := find(child, key); x != nil {
				return x
			}
		}
	case []any:
		for _, child := range t {
			if x := find(child, key); x != nil {
				return x
			}
		}
	}
	return nil
}

// findString returns the first string held under any of keys, checking keys
// in order on each object before descending.
func findString(v any, keys ...string) string {
	switch t := v.(type) {
	case map[string]any:
		for _, k := range keys {
			if s, ok := t[k].(string); ok && s != "" {
				return s
			}
		}
		for _, child := range t {
			if s := findString(child, keys...); s != "" {
				return s
			}
		}
	case []any:
		for _, child := range t {
			if s := findString(child, keys...); s != "" {
				return s
			}
		}
	}
	return ""
}

func collectStrings(v any, key string) []string {
	var out []string
	var walk func(any)
	walk = func(v any) {
		switch t := v.(type) {
		case map[string]any:
			if s, ok := t[key].(string); ok {
				out = append(out, s)
			}
			for _, child := range t {
				walk(child)
			}
		case []any:
			for _, child := range t {
				walk(child)
			}
		}
	}
	walk(v)
	return out
}
```

- [ ] **Step 4: Run, expect pass**

Run: `go test ./internal/herdr/`
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add internal/herdr && git commit -m "feat(herdr): CLI client for kinds, context, tab create, agent start"
```

---

### Task 6: `internal/app` — the flow

**Files:**
- Create: `internal/app/app.go`, `internal/app/app_test.go`

**Interfaces:**
- Consumes: `gitx.Repo`, `herdr.Client`, `slug.Slug`, `slug.AgentName`
- Produces:
  - `type Request struct { Kind, Cwd, WorkspaceID string; Worktree bool; Branch string; UseExisting bool }`
  - `type Result struct { Dir, Branch, Base, PaneID, AgentName string }`
  - `type Deps struct { Git *gitx.Repo; Herdr *herdr.Client; Out io.Writer; Dry bool }` — Git nil outside a repo
  - `func Execute(d Deps, req Request) (Result, error)`
  - `var ErrNoRepo, ErrBranchExists error`; `type DirExistsError struct{ Dir string }`; `type AgentStartError struct{ PaneID string; Err error }`
  - `func LastKind(stateDir string) string`; `func SaveLastKind(stateDir, kind string) error`

- [ ] **Step 1: Failing tests**

`internal/app/app_test.go`:
```go
package app

import (
	"bytes"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/MomePP/herdr-agent-tab/internal/gitx"
	"github.com/MomePP/herdr-agent-tab/internal/herdr"
	"github.com/MomePP/herdr-agent-tab/internal/run"
)

func initRepo(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	dir, _ = filepath.EvalSymlinks(dir)
	x := run.Exec{}
	for _, args := range [][]string{
		{"init", "-b", "develop"},
		{"config", "user.email", "t@example.com"},
		{"config", "user.name", "t"},
		{"commit", "--allow-empty", "-m", "init"},
	} {
		if _, err := x.Run(dir, "git", args...); err != nil {
			t.Fatal(err)
		}
	}
	return dir
}

func fakeHerdr(agentStartErr error) (*herdr.Client, *run.Fake) {
	f := &run.Fake{Reply: func(name string, args []string) ([]byte, error) {
		if strings.HasPrefix(strings.Join(args, " "), "agent start") && agentStartErr != nil {
			return nil, agentStartErr
		}
		return run.Canned("/unused", "develop")(name, args)
	}}
	return herdr.NewWith("herdr", f), f
}

func argv(f *run.Fake, i int) string { return strings.Join(f.Calls[i], " ") }

func TestLocal(t *testing.T) {
	dir := initRepo(t)
	repo, _ := gitx.Open(run.Exec{}, dir)
	client, f := fakeHerdr(nil)
	res, err := Execute(Deps{Git: repo, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "claude", Cwd: dir, WorkspaceID: "wB"})
	if err != nil {
		t.Fatal(err)
	}
	if res.Dir != dir || res.PaneID != "wD:p9" || res.AgentName != "claude-develop" {
		t.Fatalf("res = %+v", res)
	}
	if argv(f, 0) != "herdr tab create --workspace wB --cwd "+dir+" --label claude --focus" {
		t.Fatalf("tab create argv = %q", argv(f, 0))
	}
	if argv(f, 2) != "herdr agent start claude-develop --kind claude --pane wD:p9" {
		t.Fatalf("agent start argv = %q", argv(f, 2))
	}
}

func TestLocalOutsideRepo(t *testing.T) {
	dir := t.TempDir()
	client, f := fakeHerdr(nil)
	res, err := Execute(Deps{Git: nil, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "omp", Cwd: dir, WorkspaceID: "wB"})
	if err != nil || res.AgentName != "omp" {
		t.Fatalf("res=%+v err=%v", res, err)
	}
	if !strings.Contains(argv(f, 0), "--cwd "+dir+" --label omp") {
		t.Fatalf("argv = %q", argv(f, 0))
	}
}

func TestWorktreeNewBranch(t *testing.T) {
	dir := initRepo(t)
	repo, _ := gitx.Open(run.Exec{}, dir)
	client, f := fakeHerdr(nil)
	res, err := Execute(Deps{Git: repo, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "claude", Cwd: dir, WorkspaceID: "wB", Worktree: true, Branch: "feature/shuttle types"})
	if err != nil {
		t.Fatal(err)
	}
	want := filepath.Join(dir, ".worktrees", "feature-shuttle-types")
	if res.Dir != want || res.Base != "develop" || res.AgentName != "claude-feature-shuttle-types" {
		t.Fatalf("res = %+v", res)
	}
	if st, err := os.Stat(want); err != nil || !st.IsDir() {
		t.Fatalf("worktree dir missing: %v", err)
	}
	if !repo.BranchExists("feature/shuttle types") || !repo.IsExcluded() {
		t.Fatal("branch should exist and .worktrees should be excluded")
	}
	if !strings.Contains(argv(f, 0), "--cwd "+want+" --label feature-shuttle-types") {
		t.Fatalf("tab create argv = %q", argv(f, 0))
	}
	if _, err := os.Stat(filepath.Join(dir, ".gitignore")); err == nil {
		t.Fatal("must not touch .gitignore")
	}
}

func TestWorktreeUsesFlowBase(t *testing.T) {
	dir := initRepo(t)
	x := run.Exec{}
	x.Run(dir, "git", "branch", "main")
	x.Run(dir, "git", "config", "gitflow.branch.develop", "develop")
	x.Run(dir, "git", "checkout", "-q", "main")
	repo, _ := gitx.Open(run.Exec{}, dir)
	client, _ := fakeHerdr(nil)
	res, err := Execute(Deps{Git: repo, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "claude", Cwd: dir, WorkspaceID: "wB", Worktree: true, Branch: "feature/x"})
	if err != nil || res.Base != "develop" {
		t.Fatalf("res=%+v err=%v", res, err)
	}
	out, _ := x.Run(dir, "git", "config", "--get", "gitflow.branch.feature/x.base")
	if strings.TrimSpace(string(out)) != "develop" {
		t.Fatalf("flow base not recorded: %q", out)
	}
}

func TestWorktreeBranchExists(t *testing.T) {
	dir := initRepo(t)
	run.Exec{}.Run(dir, "git", "branch", "feature/x")
	repo, _ := gitx.Open(run.Exec{}, dir)
	client, f := fakeHerdr(nil)
	deps := Deps{Git: repo, Herdr: client, Out: &bytes.Buffer{}}
	req := Request{Kind: "claude", Cwd: dir, WorkspaceID: "wB", Worktree: true, Branch: "feature/x"}
	if _, err := Execute(deps, req); !errors.Is(err, ErrBranchExists) {
		t.Fatalf("err = %v", err)
	}
	if len(f.Calls) != 0 {
		t.Fatal("nothing should reach herdr")
	}
	req.UseExisting = true
	res, err := Execute(deps, req)
	if err != nil || res.Base != "" {
		t.Fatalf("res=%+v err=%v", res, err)
	}
}

func TestWorktreeDirExists(t *testing.T) {
	dir := initRepo(t)
	repo, _ := gitx.Open(run.Exec{}, dir)
	os.MkdirAll(repo.WorktreeDir("feature-x"), 0o755)
	client, _ := fakeHerdr(nil)
	_, err := Execute(Deps{Git: repo, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "claude", Cwd: dir, WorkspaceID: "wB", Worktree: true, Branch: "feature/x"})
	var de *DirExistsError
	if !errors.As(err, &de) || de.Dir != repo.WorktreeDir("feature-x") {
		t.Fatalf("err = %v", err)
	}
}

func TestWorktreeOutsideRepo(t *testing.T) {
	client, _ := fakeHerdr(nil)
	_, err := Execute(Deps{Git: nil, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "claude", Cwd: "/tmp", WorkspaceID: "wB", Worktree: true, Branch: "x"})
	if !errors.Is(err, ErrNoRepo) {
		t.Fatalf("err = %v", err)
	}
}

func TestAgentStartFailureKeepsTab(t *testing.T) {
	dir := initRepo(t)
	repo, _ := gitx.Open(run.Exec{}, dir)
	client, _ := fakeHerdr(errors.New("timeout"))
	_, err := Execute(Deps{Git: repo, Herdr: client, Out: &bytes.Buffer{}},
		Request{Kind: "claude", Cwd: dir, WorkspaceID: "wB"})
	var ae *AgentStartError
	if !errors.As(err, &ae) || ae.PaneID != "wD:p9" || !strings.Contains(err.Error(), "did not start") {
		t.Fatalf("err = %v", err)
	}
}

func TestDryRunTouchesNothing(t *testing.T) {
	var out bytes.Buffer
	fake := &run.Fake{Print: &out, Reply: run.Canned("/repo", "develop")}
	repo, _ := gitx.Open(fake, "/repo")
	res, err := Execute(Deps{Git: repo, Herdr: herdr.NewWith("herdr", fake), Out: &out, Dry: true},
		Request{Kind: "claude", Cwd: "/repo", WorkspaceID: "wB", Worktree: true, Branch: "feature/x"})
	if err != nil {
		t.Fatal(err)
	}
	if res.Dir != "/repo/.worktrees/feature-x" || res.Base != "develop" {
		t.Fatalf("res = %+v", res)
	}
	if _, err := os.Stat("/repo"); err == nil {
		t.Fatal("dry run must not create /repo")
	}
	for _, want := range []string{
		"(would append .worktrees/ to .git/info/exclude)",
		"$ git worktree add -b feature/x /repo/.worktrees/feature-x develop",
		"$ herdr tab create --workspace wB --cwd /repo/.worktrees/feature-x --label feature-x --focus",
		"$ herdr agent start claude-feature-x --kind claude --pane wD:p9",
	} {
		if !strings.Contains(out.String(), want) {
			t.Errorf("missing %q in:\n%s", want, out.String())
		}
	}
}

func TestLastKindRoundTrip(t *testing.T) {
	dir := t.TempDir()
	if LastKind(dir) != "" {
		t.Fatal("expected empty before save")
	}
	if err := SaveLastKind(dir, "omp"); err != nil {
		t.Fatal(err)
	}
	if LastKind(dir) != "omp" {
		t.Fatalf("got %q", LastKind(dir))
	}
	if err := SaveLastKind("", "omp"); err != nil {
		t.Fatal("empty state dir should be a no-op")
	}
}
```

- [ ] **Step 2: Run, expect compile failure**

Run: `go test ./internal/app/`
Expected: FAIL — undefined symbols.

- [ ] **Step 3: Implement**

`internal/app/app.go`:
```go
// Package app is the flow: optional worktree, then a tab, then the agent.
package app

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/MomePP/herdr-agent-tab/internal/gitx"
	"github.com/MomePP/herdr-agent-tab/internal/herdr"
	"github.com/MomePP/herdr-agent-tab/internal/slug"
)

type Request struct {
	Kind        string
	Cwd         string
	WorkspaceID string
	Worktree    bool
	Branch      string
	// UseExisting: Branch already exists and the user chose to check it out.
	UseExisting bool
}

type Result struct {
	Dir       string
	Branch    string
	Base      string // "" when an existing branch was used
	PaneID    string
	AgentName string
}

type Deps struct {
	Git   *gitx.Repo // nil outside a repository
	Herdr *herdr.Client
	Out   io.Writer
	Dry   bool // skip filesystem checks and writes; commands are echoed by the Fake runner
}

var (
	ErrNoRepo       = errors.New("a worktree needs a git repository; this directory is not in one")
	ErrBranchExists = errors.New("branch already exists")
)

type DirExistsError struct{ Dir string }

func (e *DirExistsError) Error() string { return "worktree directory already exists: " + e.Dir }

// AgentStartError means the tab is open at a shell but the agent did not come up.
type AgentStartError struct {
	PaneID string
	Err    error
}

func (e *AgentStartError) Error() string {
	return fmt.Sprintf("tab opened (pane %s) but the agent did not start: %v", e.PaneID, e.Err)
}
func (e *AgentStartError) Unwrap() error { return e.Err }

// Execute runs the flow. Nothing is half-done on error: a failure before the
// tab leaves no tab; a failure after the worktree says the worktree exists.
func Execute(d Deps, req Request) (Result, error) {
	res := Result{Dir: req.Cwd}
	label := req.Kind
	nameSlug := ""
	if d.Git != nil {
		if b, err := d.Git.CurrentBranch(); err == nil {
			nameSlug = slug.Slug(b)
		}
	}

	if req.Worktree {
		if d.Git == nil {
			return res, ErrNoRepo
		}
		branch := strings.TrimSpace(req.Branch)
		if branch == "" {
			return res, errors.New("branch name is required")
		}
		s := slug.Slug(branch)
		res.Dir = d.Git.WorktreeDir(s)
		if !d.Dry {
			if _, err := os.Stat(res.Dir); err == nil {
				return res, &DirExistsError{Dir: res.Dir}
			}
		}
		exists := d.Git.BranchExists(branch)
		if exists && !req.UseExisting {
			return res, ErrBranchExists
		}
		res.Branch = branch
		if !exists {
			res.Base = d.Git.FlowDevelop()
			if res.Base == "" {
				cur, err := d.Git.CurrentBranch()
				if err != nil {
					return res, err
				}
				res.Base = cur
			}
		}
		if !d.Git.IsExcluded() {
			if d.Dry {
				fmt.Fprintln(d.Out, "(would append .worktrees/ to .git/info/exclude)")
			} else if err := d.Git.AppendExclude(); err != nil {
				return res, err
			}
		}
		if err := d.Git.AddWorktree(res.Dir, branch, res.Base, !exists); err != nil {
			return res, err
		}
		if !exists && d.Git.HasFlow() {
			if err := d.Git.RecordFlowBase(branch, res.Base); err != nil {
				return res, err
			}
		}
		label, nameSlug = s, s
	}

	pane, err := d.Herdr.TabCreate(req.WorkspaceID, res.Dir, label)
	if err != nil {
		if req.Worktree {
			return res, fmt.Errorf("worktree created at %s but the tab did not open: %w", res.Dir, err)
		}
		return res, err
	}
	res.PaneID = pane
	res.AgentName = slug.AgentName(req.Kind, nameSlug, d.Herdr.AgentNames())
	if err := d.Herdr.AgentStart(res.AgentName, req.Kind, pane); err != nil {
		return res, &AgentStartError{PaneID: pane, Err: err}
	}
	return res, nil
}

const lastKindFile = "last-agent"

// LastKind is the previously chosen agent kind, or "".
func LastKind(stateDir string) string {
	if stateDir == "" {
		return ""
	}
	b, err := os.ReadFile(filepath.Join(stateDir, lastKindFile))
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(b))
}

func SaveLastKind(stateDir, kind string) error {
	if stateDir == "" {
		return nil
	}
	if err := os.MkdirAll(stateDir, 0o755); err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(stateDir, lastKindFile), []byte(kind+"\n"), 0o644)
}
```

- [ ] **Step 4: Run, expect pass**

Run: `go test ./internal/app/`
Expected: `ok`. If `TestDryRunTouchesNothing` fails on the agent-name line, check that `slug.AgentName` received `"feature-x"` — the dry path must set `nameSlug` from the branch slug, not the canned current branch.

- [ ] **Step 5: Commit**

```bash
git add internal/app && git commit -m "feat(app): worktree → tab → agent flow with dry run and last-kind memory"
```

---

### Task 7: `internal/picker` — the popup forms

**Files:**
- Create: `internal/picker/picker.go`

**Interfaces:**
- Produces:
  - `type Options struct { Kinds []string; LastKind, CurrentBranch, Prefix string; InRepo bool }`
  - `type Choice struct { Kind string; Worktree bool; Branch string }`
  - `var ErrCancelled error`
  - `func Run(o Options) (Choice, error)`
  - `func Confirm(title string) (bool, error)` — false on Esc
  - `func Pause(w io.Writer, msg string)` — print, wait for Enter (keeps the popup readable)

No unit test: huh needs a TTY. Task 9 exercises it by hand.

- [ ] **Step 1: Implement**

`internal/picker/picker.go`:
```go
// Package picker is the popup UI. It only collects answers; app does the work.
package picker

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/charmbracelet/huh"
)

type Options struct {
	Kinds         []string
	LastKind      string
	CurrentBranch string
	Prefix        string // git-flow feature prefix, prefilled into the branch field
	InRepo        bool
}

type Choice struct {
	Kind     string
	Worktree bool
	Branch   string
}

var ErrCancelled = errors.New("cancelled")

// Run asks agent, where, and (for a worktree) branch. Outside a repo only the
// agent question is shown.
func Run(o Options) (Choice, error) {
	if len(o.Kinds) == 0 {
		return Choice{}, errors.New("no supported agent found on PATH")
	}
	c := Choice{Kind: o.LastKind}
	if !contains(o.Kinds, c.Kind) {
		c.Kind = o.Kinds[0]
	}
	where := "local"
	branch := o.Prefix

	kindOpts := make([]huh.Option[string], 0, len(o.Kinds))
	for _, k := range o.Kinds {
		kindOpts = append(kindOpts, huh.NewOption(k, k))
	}
	groups := []*huh.Group{
		huh.NewGroup(huh.NewSelect[string]().Title("Agent").Options(kindOpts...).Value(&c.Kind)),
	}
	if o.InRepo {
		groups = append(groups,
			huh.NewGroup(huh.NewSelect[string]().Title("Where").Options(
				huh.NewOption("local · "+o.CurrentBranch, "local"),
				huh.NewOption("worktree · new branch", "worktree"),
			).Value(&where)),
			huh.NewGroup(huh.NewInput().Title("Branch").Value(&branch).Validate(validBranch)).
				WithHideFunc(func() bool { return where != "worktree" }),
		)
	}
	if err := huh.NewForm(groups...).Run(); err != nil {
		if errors.Is(err, huh.ErrUserAborted) {
			return Choice{}, ErrCancelled
		}
		return Choice{}, err
	}
	c.Worktree = o.InRepo && where == "worktree"
	c.Branch = strings.TrimSpace(branch)
	return c, nil
}

func validBranch(s string) error {
	s = strings.TrimSpace(s)
	if s == "" || strings.HasSuffix(s, "/") {
		return errors.New("branch name is required")
	}
	if strings.ContainsAny(s, " \t~^:?*[\\") {
		return errors.New("not a valid branch name")
	}
	return nil
}

// Confirm asks a yes/no question; Esc counts as no.
func Confirm(title string) (bool, error) {
	ok := false
	err := huh.NewConfirm().Title(title).Affirmative("Open worktree").Negative("Cancel").Value(&ok).Run()
	if errors.Is(err, huh.ErrUserAborted) {
		return false, nil
	}
	return ok, err
}

// Pause shows msg and waits for Enter so the popup does not close on top of it.
func Pause(w io.Writer, msg string) {
	fmt.Fprintln(w, msg)
	fmt.Fprint(w, "\npress enter to close")
	_, _ = bufio.NewReader(os.Stdin).ReadString('\n')
}

func contains(list []string, s string) bool {
	for _, v := range list {
		if v == s {
			return true
		}
	}
	return false
}
```

- [ ] **Step 2: Build**

Run: `go build ./... && go vet ./...`
Expected: no output. If `WithHideFunc` or `huh.ErrUserAborted` is undefined, run `go doc github.com/charmbracelet/huh Group` / `go doc github.com/charmbracelet/huh | grep -i abort` and use the name that version exports (older huh: `ErrUserAborted`; hide via `.WithHide(bool)` requires rebuilding the form — prefer upgrading huh).

- [ ] **Step 3: Commit**

```bash
git add internal/picker && git commit -m "feat(picker): huh forms for agent, where, and branch"
```

---

### Task 8: `cmd/agent-tab` — wire `new` and `picker`

**Files:**
- Modify: `cmd/agent-tab/main.go` (replace the stub)
- Create: `cmd/agent-tab/main_test.go`

**Interfaces:**
- Consumes: everything above
- Produces: `func dryRun(w io.Writer, cwd, kind string, worktree bool, branch string) error`

- [ ] **Step 1: Failing golden test**

`cmd/agent-tab/main_test.go`:
```go
package main

import (
	"bytes"
	"testing"
)

func TestDryRunGolden(t *testing.T) {
	var out bytes.Buffer
	if err := dryRun(&out, "/repo", "claude", true, "feature/x"); err != nil {
		t.Fatal(err)
	}
	want := `$ git rev-parse --path-format=absolute --git-common-dir
$ git rev-parse --abbrev-ref HEAD
$ git rev-parse --verify --quiet refs/heads/feature/x
$ git config --get gitflow.branch.develop
$ git rev-parse --abbrev-ref HEAD
$ git check-ignore -q .worktrees
(would append .worktrees/ to .git/info/exclude)
$ git worktree add -b feature/x /repo/.worktrees/feature-x main
$ git config --get gitflow.branch.develop
$ herdr tab create --workspace wDRY --cwd /repo/.worktrees/feature-x --label feature-x --focus
$ herdr agent list
$ herdr agent start claude-feature-x --kind claude --pane wD:p9
→ tab at /repo/.worktrees/feature-x, agent claude-feature-x in pane wD:p9
`
	if out.String() != want {
		t.Fatalf("got:\n%s\nwant:\n%s", out.String(), want)
	}
}

func TestDryRunLocal(t *testing.T) {
	var out bytes.Buffer
	if err := dryRun(&out, "/repo", "omp", false, ""); err != nil {
		t.Fatal(err)
	}
	if !bytes.Contains(out.Bytes(), []byte("--cwd /repo --label omp")) ||
		!bytes.Contains(out.Bytes(), []byte("agent start omp-main")) {
		t.Fatalf("got:\n%s", out.String())
	}
}
```

- [ ] **Step 2: Run, expect failure**

Run: `go test ./cmd/agent-tab/`
Expected: FAIL — `undefined: dryRun`.

- [ ] **Step 3: Implement**

`cmd/agent-tab/main.go` (full replacement):
```go
// agent-tab is a herdr plugin: open an agent in a new tab of the current
// space, on the checkout or a fresh .worktrees/<slug> worktree.
//
//	agent-tab new      action bound to a key; opens the picker popup
//	agent-tab picker   runs inside the popup
package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"

	"github.com/MomePP/herdr-agent-tab/internal/app"
	"github.com/MomePP/herdr-agent-tab/internal/gitx"
	"github.com/MomePP/herdr-agent-tab/internal/herdr"
	"github.com/MomePP/herdr-agent-tab/internal/picker"
	"github.com/MomePP/herdr-agent-tab/internal/run"
)

const pluginID = "momepp.agent-tab"

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}
	var err error
	switch os.Args[1] {
	case "new":
		err = cmdNew(os.Args[2:])
	case "picker":
		err = cmdPicker()
	default:
		usage()
		os.Exit(2)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "agent-tab:", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: agent-tab new [--dry-run --agent K --where local|worktree --branch B] | agent-tab picker")
}

// cmdNew is the headless action. Only a pane has a TTY, so it just opens the
// picker popup — unless --dry-run, which prints the flow for the given answers.
func cmdNew(args []string) error {
	fs := flag.NewFlagSet("new", flag.ContinueOnError)
	dry := fs.Bool("dry-run", false, "print the commands instead of opening the picker")
	kind := fs.String("agent", "claude", "agent kind (dry-run only)")
	where := fs.String("where", "local", "local or worktree (dry-run only)")
	branch := fs.String("branch", "", "branch name (dry-run, worktree only)")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if !*dry {
		return herdr.New(run.Exec{}).OpenPicker(pluginID)
	}
	cwd, err := os.Getwd()
	if err != nil {
		return err
	}
	return dryRun(os.Stdout, cwd, *kind, *where == "worktree", *branch)
}

// dryRun walks Execute against canned replies: a repo at cwd on "main",
// no git-flow, no existing branches, workspace "wDRY".
func dryRun(w io.Writer, cwd, kind string, worktree bool, branch string) error {
	fake := &run.Fake{Print: w, Reply: run.Canned(cwd, "main")}
	repo, _ := gitx.Open(fake, cwd)
	deps := app.Deps{Git: repo, Herdr: herdr.NewWith("herdr", fake), Out: w, Dry: true}
	res, err := app.Execute(deps, app.Request{
		Kind: kind, Cwd: cwd, WorkspaceID: "wDRY", Worktree: worktree, Branch: branch,
	})
	if err != nil {
		return err
	}
	fmt.Fprintf(w, "→ tab at %s, agent %s in pane %s\n", res.Dir, res.AgentName, res.PaneID)
	return nil
}

// cmdPicker runs inside the popup: ask, then act. Errors are shown and held
// until Enter so the popup does not vanish with the message.
func cmdPicker() error {
	client := herdr.New(run.Exec{})
	ctx, err := client.Context()
	if err != nil {
		return hold(err)
	}
	kinds, err := client.AgentKinds()
	if err != nil {
		return hold(err)
	}
	repo, _ := gitx.Open(run.Exec{}, ctx.Cwd) // nil outside a repo: local only

	opts := picker.Options{
		Kinds:    herdr.Installed(kinds),
		LastKind: app.LastKind(stateDir()),
		InRepo:   repo != nil,
	}
	if repo != nil {
		opts.CurrentBranch, _ = repo.CurrentBranch()
		opts.Prefix = repo.FlowPrefix()
	}
	choice, err := picker.Run(opts)
	if errors.Is(err, picker.ErrCancelled) {
		return nil
	}
	if err != nil {
		return hold(err)
	}

	req := app.Request{
		Kind: choice.Kind, Cwd: ctx.Cwd, WorkspaceID: ctx.WorkspaceID,
		Worktree: choice.Worktree, Branch: choice.Branch,
	}
	if choice.Worktree && repo.BranchExists(choice.Branch) {
		ok, err := picker.Confirm(fmt.Sprintf("Branch %q already exists. Open a worktree on it?", choice.Branch))
		if err != nil {
			return hold(err)
		}
		if !ok {
			return nil
		}
		req.UseExisting = true
	}
	_ = app.SaveLastKind(stateDir(), choice.Kind)

	if _, err := app.Execute(app.Deps{Git: repo, Herdr: client, Out: os.Stdout}, req); err != nil {
		return hold(err)
	}
	return nil
}

func stateDir() string { return os.Getenv("HERDR_PLUGIN_STATE_DIR") }

func hold(err error) error {
	picker.Pause(os.Stdout, "error: "+err.Error())
	return err
}
```

- [ ] **Step 4: Run all tests, expect pass**

Run: `go test ./... && go vet ./...`
Expected: every package `ok`. If the golden differs only in the order of `git` read calls, update the golden to the actual order — the argv *content* is the contract, not the interleaving of reads.

- [ ] **Step 5: Rebuild the linked binary and smoke the dry run**

```bash
go build -o bin/agent-tab ./cmd/agent-tab
cd ~/Developer/badminton-platform && ~/Developer/herdr-plugins/herdr-agent-tab/bin/agent-tab new --dry-run --agent claude --where worktree --branch feature/try
```
Expected: the same command list as the golden, rooted at `~/Developer/badminton-platform`.

- [ ] **Step 6: Commit**

```bash
cd ~/Developer/herdr-plugins/herdr-agent-tab && git add cmd && git commit -m "feat(cmd): new (popup / --dry-run) and picker subcommands"
```

---

### Task 9: Manual verification in herdr

No files. The plugin is already linked (Task 1) and rebuilt (Task 8).

- [ ] **Step 1: Bind a temporary key and reload**

Append to `~/.config/herdr/config.toml` (this is the dotfiles repo; Task 10 makes it permanent):
```toml
[[keys.command]]
key = "prefix+n"
type = "plugin_action"
command = "momepp.agent-tab.new"
description = "new agent tab here"
```
Run: `herdr config check && herdr server reload-config`
Expected: `config: ok`, then `"status":"applied"` with empty diagnostics.

- [ ] **Step 2: Restart the server so the linked plugin loads** — *the user does this, from outside herdr*: `Ctrl-a q`, then `herdr server stop && herdr`.

- [ ] **Step 3: Local mode.** In the `badminton-platform` space, `Ctrl-a n` → `claude` → `local · develop`.
Expected: a new focused tab labelled `claude` at the repo root with Claude running; `herdr agent list` shows `claude-develop`.

- [ ] **Step 4: Worktree mode.** `Ctrl-a n` → `claude` (preselected) → `worktree · new branch` → `feature/agent-tab-try`.
Expected: tab `feature-agent-tab-try`; `git -C ~/Developer/badminton-platform worktree list` shows `.worktrees/feature-agent-tab-try  [feature/agent-tab-try]`; `.git/info/exclude` gained `.worktrees/`; `git status` in the main checkout is clean.

- [ ] **Step 5: Existing branch.** `Ctrl-a n` → worktree → `feature/agent-tab-try` again.
Expected: the confirm prompt; **Cancel** leaves nothing behind; running once more and choosing **Open worktree** fails with "worktree directory already exists: …" (the directory from Step 4) and waits for Enter.

- [ ] **Step 6: Clean the playground**
```bash
cd ~/Developer/badminton-platform && git worktree remove .worktrees/feature-agent-tab-try && git branch -D feature/agent-tab-try
```
Close the two test tabs (`Ctrl-a Ctrl-x`).

- [ ] **Step 7: Publish the plugin**
```bash
cd ~/Developer/herdr-plugins/herdr-agent-tab
gh repo create MomePP/herdr-agent-tab --public --source . --push
git tag v0.1.0 && git push --tags
```

---

### Task 10: Dotfiles — drop herdr-plus, bind `Ctrl-a n`, update the cheatsheet

Repo `~/.config`, branch `feature/herdr-native-workflow`.

**Files:**
- Modify: `herdr/config.toml` (the `# ── plugins` block)
- Modify: `.gitignore` (herdr section)
- Delete: `herdr/plugins/config/cloudmanic.herdr-plus/`
- Modify: `.claude/knowledges/herdr-keymap.md`

- [ ] **Step 1: Uninstall herdr-plus**

```bash
herdr plugin uninstall cloudmanic.herdr-plus && herdr plugin list | grep -c '^- '
```
Expected: `3`.

- [ ] **Step 2: Rewrite the plugin bindings in `herdr/config.toml`**

Replace the two herdr-plus `[[keys.command]]` entries (`prefix+g` and `prefix+.`) and their comment with:
```toml
# agent-tab: open an agent in a new tab of THIS space — on the checkout, or on a
# fresh .worktrees/<slug> worktree. herdr's own Ctrl-a G makes a space per
# worktree; this keeps space = project, tab = agent. https://github.com/MomePP/herdr-agent-tab
[[keys.command]]
key = "prefix+n"
type = "plugin_action"
command = "momepp.agent-tab.new"
description = "new agent tab here"
```
Also change the block's opening comment line `# Plugin config lives in plugins/config/<id>/ (herdr-plus project + worktree` … to `# Plugin config lives in plugins/config/<id>/ (nothing tracked; herdr manages it).`
Remove the temporary binding appended in Task 9 so `prefix+n` appears once.

- [ ] **Step 3: Restore the `.gitignore` herdr section**

Replace the whole herdr block with:
```
# herdr: track only config.toml; ignore runtime state (logs, sockets, session)
# and the plugins herdr manages itself
/herdr/*
!/herdr/config.toml
```

- [ ] **Step 4: Delete the templates and update the cheatsheet**

```bash
git rm -r herdr/plugins/config/cloudmanic.herdr-plus
```
In `.claude/knowledges/herdr-keymap.md`, replace the "Workflow" table with:
```markdown
| Key | Action |
|---|---|
| `n` | **new agent tab here** — pick the agent, then `local · <branch>` or `worktree · new branch`. Worktrees land in `<repo>/.worktrees/<slug>` (shared with superpowers), base = git-flow develop or the current branch. |
| `N` | new space on the current directory (herdr built-in) |
| `G` | new space on a fresh worktree (herdr built-in) — space-per-worktree, not this workflow |
```
and drop the two lines about `herdr-plus` templates under it. In "Plugin housekeeping", drop the hunk-diff sentence's mention of herdr-plus if any; leave the rest.

- [ ] **Step 5: Verify and commit**

```bash
herdr config check && herdr server reload-config
git status --short
git add -A && git commit -m "feat(herdr): agent-tab on Ctrl-a n; drop herdr-plus and its templates"
```
Expected: `config: ok`; status shows only the four paths above.

---

## Self-review

- **Spec coverage.** Goals → Tasks 6/8/9. Manifest → Task 1. Agent list from herdr ∩ PATH + last-kind memory → Tasks 5/6/8. Branch/base/slug rules → Tasks 3/4/6. `.worktrees/` + `info/exclude` → Tasks 4/6. Every error row → Task 6 (`ErrNoRepo`, `ErrBranchExists`, `DirExistsError`, git stderr, tab-create wrap, `AgentStartError`) and the confirm in Task 8. Testing section → Tasks 2–6 unit, Task 8 golden, Task 9 manual. Dotfiles side → Task 10. Non-goals untouched.
- **Placeholders.** None; every step has its content.
- **Type consistency.** `run.Fake{Calls, Reply, Print}` used identically in Tasks 2/5/6/8. `gitx.Open(r, dir)` argument order matches everywhere. `herdr.NewWith(bin, r)` matches. `app.Deps{Git, Herdr, Out, Dry}` and `app.Request` fields match Task 8. `picker.Options` fields match Task 8. The dry-run golden's argv strings are exactly those `gitx`/`herdr` emit.
