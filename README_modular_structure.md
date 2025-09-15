# 🚀 Modular Task Visualization System

Your ASCII task visualization system has been restructured into a clean, professional, modular architecture!

## 📁 New File Structure

```
lua/notes/
├── init.lua          # Main module with setup() function and high-level API
├── plot.lua          # Pure plotting functions (histograms, pie charts, etc.)  
└── utils.lua         # Data formatting and utility functions

plugin/
└── notes.lua         # Your existing notes plugin (integration point)

# Demo and examples
├── modular_demo.lua      # Demonstrates the new modular API
├── integration_new.lua   # Integration examples and patterns
└── README_modular_structure.md  # This file
```

## ⚡ Quick Start

```lua
-- 1. Setup (add to your notes.lua plugin)
local notes_viz = require('notes')
notes_viz.setup({
    charts = { pie_chart = { style = "unicode" } },
    display = { use_emojis = true }
})

-- 2. Use high-level functions
notes_viz.dashboard("personal")      -- Full dashboard
notes_viz.task_states("work")        -- Pie chart of task states
notes_viz.daily_completions("personal", 7)  -- Week of completions

-- 3. Or use convenience shortcuts
notes_viz.personal()    -- Personal dashboard
notes_viz.work()        -- Work dashboard
notes_viz.completions() -- Personal completions (7 days default)
```

## 🎯 API Levels

### Level 1: Convenience Functions (Simplest)
```lua
local notes_viz = require('notes')
notes_viz.personal()       -- One-line personal dashboard
notes_viz.work()           -- One-line work dashboard
notes_viz.completions(14)  -- Two weeks of completions
notes_viz.states()         -- Task states pie chart
```

### Level 2: High-Level Functions (Configurable)
```lua
notes_viz.dashboard("personal", {compact = true})
notes_viz.daily_completions("work", 30, {width = 60})
notes_viz.task_states("personal", {style = "pattern"})
notes_viz.recent_activity("work", 15, {show_borders = false})
notes_viz.productivity_trend("personal", 21, {height = 15})
```

### Level 3: Direct Plotting (Maximum Control)
```lua
local custom_data = {{label="Done", value=25}, {label="Todo", value=8}}
local chart = notes_viz.plot.pie_chart(custom_data, {
    style = "unicode", 
    radius = 12
})
for _, line in ipairs(chart) do print(line) end
```

### Level 4: Raw Utilities (Data Processing)
```lua
local sql_results = db:eval("SELECT date, count FROM stats")
local chart_data = notes_viz.utils.sql_to_chart_data(sql_results, "date", "count")
local formatted_date = notes_viz.utils.format_date("2024-09-11", "medium")
```

## ⚙️ Configuration System

The `setup()` function accepts a comprehensive configuration:

```lua
notes_viz.setup({
    -- Database paths (auto-detected from environment)
    database = {
        personal_path = nil,  -- Uses ZK_PERSO_TASK_DB_PATH  
        work_path = nil       -- Uses ZK_WORK_TASK_DB_PATH
    },
    
    -- Chart styling defaults
    charts = {
        histogram = { width = 50, show_values = true },
        pie_chart = { radius = 8, style = "solid", show_legend = true },
        line_plot = { width = 60, height = 15, show_axes = true },
        table = { show_borders = true, max_rows = 10 }
    },
    
    -- Data processing preferences  
    data = {
        date_format = "short",        -- "short", "medium", "long", "relative"
        truncate_length = 30,         -- Max characters for task names
        productivity_weights = {      -- Custom scoring formula
            created = 1,
            completed = 2,
            carried_over = -1
        }
    },
    
    -- Display options
    display = {
        use_emojis = true,   -- ✅🚀📝 vs FINISHED/IN_PROGRESS/CREATED
        show_debug = false   -- Debug logging
    }
})
```

## 🔌 Integration Options

### Option 1: Add to Existing notes.lua
Seamlessly integrate into your current plugin - just add a few lines to the end.

### Option 2: Separate Plugin File  
Create `plugin/task-viz.lua` for complete separation and custom keybindings.

### Option 3: Popup Window Integration
Show charts in floating windows with escape-to-close functionality.

## 🎨 Chart Types & Styles

### 📊 Histograms
```lua
notes_viz.plot.histogram(data, {width = 50, show_values = true})
```
Perfect for: daily completions, weekly patterns, frequency distributions

### 🥧 Pie Charts (3 Styles!)
```lua
-- Solid style (density patterns)
notes_viz.plot.pie_chart(data, {style = "solid", radius = 10})

-- Pattern style (geometric patterns) 
notes_viz.plot.pie_chart(data, {style = "pattern", radius = 8})

-- Unicode style (circular characters)
notes_viz.plot.pie_chart(data, {style = "unicode", radius = 6})
```
Perfect for: task state distribution, category breakdowns

### 📋 Tables
```lua
notes_viz.plot.table(data, {headers = ["Task", "State", "Date"], show_borders = true})
```
Perfect for: recent activity, task lists, detailed breakdowns

### 📈 Line Plots
```lua
notes_viz.plot.line_plot(data, {width = 60, height = 12, show_axes = true})
```
Perfect for: productivity trends, progress over time, comparisons

## 🛠 Utility Functions

### Data Conversion
```lua
-- SQL results → Chart data
chart_data = notes_viz.utils.sql_to_chart_data(sql_results, "label_col", "value_col")

-- SQL results → Table data  
table_data = notes_viz.utils.sql_to_table_data(sql_results, ["col1", "col2", "col3"])
```

### Text Enhancement
```lua
-- Add contextual emojis
enhanced_state = notes_viz.utils.add_state_emoji("FINISHED")    -- "✅ FINISHED"
enhanced_event = notes_viz.utils.add_event_emoji("task_completed")  -- "✅ task_completed"

-- Format dates consistently
short_date = notes_viz.utils.format_date("2024-09-11", "short")   -- "09/11"
medium_date = notes_viz.utils.format_date("2024-09-11", "medium") -- "Sep 11"
relative_date = notes_viz.utils.relative_date("2024-09-11")       -- "2 days ago"

-- Clean and truncate text
clean_text = notes_viz.utils.clean_task_text("- [x] Review PR [ ](task://uuid)")  -- "Review PR"
short_text = notes_viz.utils.truncate_text("Very long task description...", 20)   -- "Very long task de..."
```

### Mathematical Operations
```lua
-- Custom productivity scoring
score = notes_viz.utils.calculate_productivity_score(5, 8, 2, {
    created = 1, completed = 3, carried_over = -2
})  -- Result: 5*1 + 8*3 + 2*(-2) = 25

-- Date ranges for queries
start_date, end_date = notes_viz.utils.date_range(14)  -- Last 14 days

-- Group data by time periods
weekly_data = notes_viz.utils.group_by_period(daily_data, "week")
monthly_data = notes_viz.utils.group_by_period(daily_data, "month")

-- Smooth data trends
smoothed = notes_viz.utils.moving_average(data, 3)  -- 3-period moving average
```

## ✨ Key Benefits

### 🏗 **Clean Architecture**
- **Separation of concerns**: plotting ≠ data processing ≠ database logic
- **Single responsibility**: each module does one thing well
- **Testable**: each function can be tested independently

### ⚙️ **Configurable Everything**  
- **Global defaults**: set once, apply everywhere
- **Per-call overrides**: customize individual charts
- **Multiple styles**: solid, pattern, unicode pie charts

### 🔌 **Flexible Integration**
- **Multiple API levels**: from one-liners to full control
- **Backward compatible**: existing code still works
- **Future-proof**: easy to extend and modify

### 📦 **Reusable Components**
- **Utility functions**: use independently  
- **Pure plotting**: works with any data source
- **Composable**: mix and match functions

### 🚀 **Production Ready**
- **Error handling**: graceful fallbacks for missing data
- **Performance optimized**: efficient algorithms and caching
- **Cross-compatible**: works in Neovim and standalone Lua

## 🎯 Integration Commands

Add these to your notes.lua for instant access:

```lua
-- Basic commands
:ZkTaskStats          " Personal dashboard
:ZkWorkStats         " Work dashboard  
:ZkTaskCompletions 14 " 14 days of completions

-- Keybindings
<leader>nts  " Task statistics dashboard
<leader>ntw  " Work task statistics  
<leader>ntc  " Task completions chart
```

## 📊 Example Output

Your beautiful ASCII charts now look like this:

```
🥧 Current Task States Distribution (CIRCULAR!)
═════════════════════════════════════════════════
          █          
      ██████▓▓▓      
    ████████▓▓▓▓▓    
   ████████▓▓▓▓▓▓▓   
  █████████▓▓▓▓▓▓▓▓  
  █████████▓▓▓▓▓▓▓▓  
 ██████████▓▓▓▓▓▓▓▓▓ 
 ██████████▓▓▓▓▓▓▓▒▒ 
 ██████████▓▓▓▓▒▒▒▒▒ 
 ██████████▓▓▒▒▒▒▒▒▒ 
██████████▒▒▒▒▒▒▒▒▒▒▒
 ██████████▒▒▒▒▒▒▒▒▒ 
 ██████████▒▒▒▒▒▒▒▒▒ 
 ██████████░▒▒▒▒▒▒▒▒ 
 ██████████░▒▒▒▒▒▒▒▒ 
  █████████░░▒▒▒▒▒▒  
  █████████░░▒▒▒▒▒▒  
   ████████░░▒▒▒▒▒   
    ███████░░░▒▒▒    
      █████░░░▒      
          █          

Legend:
█ ✅ FINISHED - 52.1% (25)
▓ 🚀 IN_PROGRESS - 16.7% (8)
▒ 📝 CREATED - 25.0% (12)
░ 🗑️ DELETED - 6.2% (3)
```

## 🚀 Next Steps

1. **Test the demo**: `lua modular_demo.lua`
2. **Choose integration**: Pick from the 3 integration options
3. **Customize config**: Set your chart preferences  
4. **Add commands**: Create your preferred keybindings
5. **Enjoy insights**: Start visualizing your task patterns!

Your event-sourced task tracking system now has **professional-grade ASCII visualization** capabilities that rival any graphical dashboard! 📊✨

The modular architecture makes it easy to extend, customize, and maintain - perfect for your sophisticated workflow needs.
