# Neovim LSP Subsystem

This directory contains a fully modular, declarative, self‑maintaining LSP architecture for Neovim.  
It is designed for portability, clarity, and zero duplication.

The system is built around four core ideas:

1. Each LSP server has its own config file.
2. A single text file declares which servers should be installed.
3. Commands manage the install list and config files.
4. Namespace tools keep the entire system consistent and portable.

---

## Directory Layout

```
lua/<namespace>/plugins/lsp/
  lspconfig.lua
  servers/
    new_server.template
    <server>.lua
```

### Namespace

The namespace is the single directory inside `lua/`.

Examples:

```
lua/doc/
lua/jeff/
lua/alex/
```

This namespace is used in all `require()` paths and is fully portable.

---

# LSP Commands

The subsystem exposes several Neovim commands for managing servers, configs, and validation.

### **List all configured servers**

```
:LspList
```

### **Create a new server config from the template**

```
:LspNew <server>
```

### **Edit an existing server config**

```
:LspEdit <server>
```

### **Remove a server config**

```
:LspRemove <server>
```

### **Validate all server configs**

Checks for syntax errors, missing functions, invalid return values, etc.

```
:LspValidateServers
```

### **Synchronize installed servers**

Installs everything listed in `install-these-servers`.

```
:LspSync
```

### **LSP Doctor (diagnostics UI)**

Runs a full diagnostic pass and displays:

- missing server files
- load errors
- invalid configs
- runtime exceptions

Output appears in:

- a floating window (press `q` to close)
- the quickfix list (`:copen`)

```
:LspDoctor
```

---

# Namespace Management

Two scripts manage the namespace:

- `rename_neovim_namespace.sh`
- `validate_neovim_namespace.sh`

Both are safe, reversible, and portable.

---

## rename_neovim_namespace.sh

Renames the current namespace to a new one and updates all references.

### Usage

```
./rename_neovim_namespace.sh <newname>
```

Example:

```
./rename_neovim_namespace.sh jeff
```

### What it does

- Detects the current namespace automatically
- Renames:

```
lua/<old>/ → lua/<new>/
```

- Rewrites all references:
  - `require("<old>.plugins.lsp")`
  - `<old>.plugins.lsp`
  - `lua/<old>/`

- Skips:
  - `.git/`
  - `node_modules/`
  - swap files
  - backup files

### Notes

- Fully reversible
- Can be run multiple times
- Does not assume the original namespace

---

## validate_neovim_namespace.sh

Checks for consistency between:

- The namespace directory
- Lua require paths
- LSP loader paths
- Directory structure

### Usage

```
./validate_neovim_namespace.sh
```

### What it checks

- Missing references to the current namespace
- Incorrect require paths
- Incorrect directory paths
- Mixed namespaces
- Extra or missing namespace directories

### Output

- Prints each issue found
- Exits non‑zero if inconsistencies exist
- Prints `namespace valid.` when everything matches

---

# Bootstrapping a New Machine

1. Clone your dotfiles
2. Open Neovim
3. Run:

```
:LspSync
:LspValidateServers
:LspDoctor
```

4. Everything installs and validates automatically
