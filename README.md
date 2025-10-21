# Neovim Configuration

A modern Neovim configuration built with `mini.deps` and focused on developer productivity.

## Keybinding System

This configuration uses a systematic approach to keybindings with logical categories and consistent patterns.

### Core Philosophy

- **Leader-based organization**: Most commands use `<leader>` prefix with mnemonic categories
- **Consistent patterns**: Similar operations follow similar key patterns
- **Dynamic context**: Some keymaps appear only when relevant (debugging, LSP)
- **Vim-native extensions**: Extend familiar vim patterns rather than replace them

### Main Categories

| Prefix | Category | Description |
|--------|----------|-------------|
| `<leader><leader>` | **Command Palette** | Quick access to all commands |
| `<leader>s*` | **Search** | All search operations (files, buffers, help, etc.) |
| `<leader>f*` | **Files** | File operations and navigation |
| `<leader>g*` | **Git** | Git operations and GitHub integration |
| `<leader>u*` | **UI** | Interface toggles and visual enhancements |
| `<leader>d*` | **Debug** | DAP debugging (dynamic when active) |
| `<leader>l*` | **LSP** | Language server operations (dynamic when attached) |
| `<leader>a*` | **AI** | CodeCompanion AI assistance (normal + visual) |
| `<leader>v*` | **Visit** | MiniVisits path management |
| `<leader>b*` | **Buffers** | Buffer operations |
| `<leader>w*` | **Windows** | Window management |
| `<leader>S*` | **Sessions** | Session management |
| `<leader>i*` | **Insert** | Text insertion helpers |
| `<leader>q*` | **Quit** | Exit operations |
| `<leader>m*` | **Mini** | Mini.deps plugin management |

### Smart Navigation Patterns

#### Buffer & Search Extensions
```lua
-- Extends vim's search metaphor
"/"            -- Search in current buffer
"<leader>/"    -- Search buffer lines (fuzzy)

-- Buffer navigation mirrors window/tmux patterns  
"<C-h>/<C-l>"  -- Navigate windows/tmux panes
"<S-h>/<S-l>"  -- Navigate buffers (same direction, buffer scope)
```

#### Quick Access
```lua
"<leader><leader>"  -- Command palette (prime real estate)
"<leader>sb"        -- Search buffers 
"<Esc>"            -- Clear search highlights
"<C-s>"            -- Save file
```

### Dynamic Keymaps

#### Debug Interface (DAP)
Keymaps appear only when debugging is active:

```lua
-- Always available (breakpoint management)
"<leader>db"  -- Toggle breakpoint
"<leader>dB"  -- Conditional breakpoint  
"<leader>dC"  -- Clear all breakpoints

-- Active only during debug sessions
"<leader>dc"  -- Continue/Start
"<leader>di"  -- Step into
"<leader>do"  -- Step over
"<leader>dO"  -- Step out
"<leader>du"  -- Debug UI toggle
"<leader>dr"  -- Restart session
"<leader>dt"  -- Terminate session
"<leader>dp"  -- Pause execution
"<leader>de"  -- Evaluate expression
```

#### LSP Operations  
Available when language server is attached:

```lua
"gd"           -- Go to definition
"gr"           -- Go to references  
"gi"           -- Go to implementation
"<leader>lr"   -- Rename symbol
"<leader>la"   -- Code actions
"<leader>lf"   -- Format document
"<leader>le"   -- Show diagnostics
-- + workspace and symbol operations
```

### Advanced Input Features

#### Smart Combos
Quick two-key combinations for common patterns:

```lua
-- Navigation
"ll"  -- End of line (g$)
"hh"  -- Start of line (g^)

-- Text editing (insert mode)
";;"  -- Add semicolon at end, keep cursor position
",,"  -- Smart comma spacing for parameters
"=="  -- Smart assignment with spacing
"::"  -- Type annotations with spacing  
"->"  -- Arrow functions/returns with spacing
".."  -- Method chaining
'""'  -- Context-aware quote wrapping

-- Quick escape
"jk"/"kj"  -- Escape from any mode
```

#### Multi-step Keys
Context-aware keys with cascading behavior:

```lua
-- Insert & Select modes
"<Tab>"    -- Expand → snippets → completion → tree → brackets
"<S-Tab>"  -- Reverse navigation through same chain
"<CR>"     -- Accept completion → handle pairs
"<BS>"     -- Handle pairs → hungry whitespace deletion
```

### Search Operations

| Keymap | Action | Description |
|--------|---------|-------------|
| `<leader><leader>` | Command Palette | Quick access to all commands |
| `<leader>sb` | Search Buffers | Find and switch to open buffers |
| `<leader>sf` | Search Files | Find files in project |
| `<leader>sg` | Search by Grep | Live grep search |
| `<leader>sh` | Search Help | Neovim help documentation |
| `<leader>sk` | Search Keymaps | Find keybindings |
| `<leader>sd` | Search Diagnostics | LSP diagnostics |
| `<leader>sw` | Search Word | Grep current word |
| `<leader>s.` | Search Recent | Recently opened files |
| `<leader>/` | Buffer Lines | Fuzzy search in current buffer |

### File Operations

| Keymap | Action | Description |
|--------|---------|-------------|
| `<leader>ff` | File Explorer | Open at current file location |
| `<leader>fF` | File Explorer (cwd) | Open at working directory |
| `<leader>fp` | File Picker | Mini.extra file picker |
| `<leader>fy` | Yank Path | Copy file path with project context |

### Git Integration

| Keymap | Action | Description |
|--------|---------|-------------|
| `<leader>gg` | Git Status | Open Neogit interface |
| `<leader>gb` | Git Branches | Browse and switch branches |
| `<leader>gc` | Git Commits | Browse commit history |
| `<leader>gh` | Git Hunks | View and navigate changes |
| `<leader>gd` | Diffview Open | Open diffview to compare working directory |
| `<leader>gD` | Diffview Close | Close the current diffview |
| `<leader>gf` | File History | Show git history for current file |
| `<leader>gF` | File History (All) | Show git history for entire repository |
| `<leader>gm` | Merge Base Diff | Compare current branch with origin/HEAD |
| `<leader>gB` | Git Blame | Toggle blame annotations |
| `<leader>go*` | Octo Actions | GitHub integration (PR, issues, reviews) |

**Diffview Buffer Mappings** (active in diffview):
- `q` - Close diffview panel
- `<tab>` / `<s-tab>` - Navigate between changed files
- `[c` / `]c` - Jump between hunks (vim diff-mode)
- `-` or `s` - Stage/unstage selected entry
- `gf` - Open file in previous tabpage

**Neogit Integration**: When in Neogit status buffer, `<leader>gd` opens diffview for quick diff access.

### UI & Visual

| Keymap | Action | Description |
|--------|---------|-------------|
| `<leader>uc` | Color Picker | Interactive palette selection |
| `<leader>ut` | Toggle Favorites | Cycle through favorite palettes |
| `<leader>uC` | Color Toggle | Quick color scheme toggle |
| `<leader>ui` | Paste Image | Insert image in document |

### AI Assistance

| Keymap | Mode | Action | Description |
|--------|------|---------|-------------|
| `<leader>aa` | **n,v** | AI Actions | CodeCompanion action palette (context-aware) |
| `<leader>ac` | **n** | AI Chat | Open CodeCompanion chat buffer |
| `<leader>ai` | **n,v** | AI Inline | CodeCompanion inline assistant |

> **Verified Commands**: Only uses [documented CodeCompanion commands](https://github.com/olimorris/codecompanion.nvim/tree/main/doc). The action palette (`<leader>aa`) provides comprehensive operations including explain, generate, refactor, documentation, and optimization for both normal and visual mode selections.

## Architecture Notes

### Plugin Organization
- **Core keymaps**: `lua/keymaps.lua` - Static, general-purpose mappings
- **Plugin-specific**: `plugin/*.lua` - Dynamic keymaps colocated with plugin setup
- **Context-aware**: `lua/autocmd.lua` - Filetype and buffer-specific mappings

### Dynamic Keymap Management
- Debug keymaps managed in `plugin/programming.lua` alongside DAP setup
- LSP keymaps in `lua/autocmd.lua` triggered on server attach
- Uses autocommands and plugin event listeners for proper lifecycle

### Conflict Resolution
- Systematic categorization prevents most conflicts
- Dynamic keymaps avoid permanent namespace pollution
- Mini.clue integration provides contextual hints

## Dependencies

Built with [mini.deps](https://github.com/echasnovski/mini.deps) for plugin management and leverages the mini.nvim ecosystem extensively.

Key plugins:
- **mini.pick** - File and buffer selection
- **mini.clue** - Keymap hints and organization  
- **mini.keymap** - Advanced keymap features (combos, multi-step)
- **nvim-dap** + **nvim-dap-ui** - Debugging interface
- **neogit** + **diffview** - Git integration
- **codecompanion** - AI assistance
