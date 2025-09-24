# Test Parent-Child Task Relationships

## Example Tasks

### Parent Task
- [ ] Implement user authentication system [ ](task://01234567-89ab-cdef-0123-456789abcdef)

### Child Tasks
- [ ] Set up OAuth configuration [ ](task://11111111-2222-3333-4444-555555555555?parent=01234567-89ab-cdef-0123-456789abcdef)
- [ ] Create login UI components [ ](task://22222222-3333-4444-5555-666666666666?parent=01234567-89ab-cdef-0123-456789abcdef)
- [ ] Implement password validation [ ](task://33333333-4444-5555-6666-777777777777?parent=01234567-89ab-cdef-0123-456789abcdef)

### Nested Child Tasks
- [ ] Create login form component [ ](task://44444444-5555-6666-7777-888888888888?parent=22222222-3333-4444-5555-666666666666)
- [ ] Add form validation [ ](task://55555555-6666-7777-8888-999999999999?parent=22222222-3333-4444-5555-666666666666)

## Features Implemented

1. **Database Schema**: Added nullable `parent_id` column to `task_events` table with automatic migration
2. **URI Parsing**: Support for `task://<uuid>?parent=<parent_uuid>` format
3. **Task Tracking**: Parent relationships are saved to database (NULL for tasks without parents)
4. **Simple Migration**: Single migration adds nullable column - old tasks get NULL, new tasks can have parent
5. **Backward Compatibility**: One consistent SQL INSERT format for all tasks
6. **Commands**: 
   - `:ZkNewTask [parent_uuid]` - Create task with optional parent
   - `:ZkNewChildTask` - Interactive child task creation with **mini.pick** parent selector
7. **Keymaps**: 
   - `<leader>nT` - New task
   - `<leader>nC` - New child task (prompts for parent UUID)
8. **Hierarchy Functions**:
   - `M.get_child_tasks(track_type, parent_uuid)` - Get child tasks
   - `M.get_parent_task(track_type, child_uuid)` - Get parent task
   - `M.get_task_hierarchy(track_type, root_uuid)` - Get full hierarchy
   - `M.show_task_hierarchy(track_type, root_uuid)` - Display hierarchy
9. **Additional Commands**:
   - `:ZkTaskHierarchy [track_type] [root_uuid]` - Show task hierarchy

## Testing Instructions

1. Save this file (should be tracked if filename matches your patterns)
2. Check database to see parent_id values are saved
3. Use `:ZkNewChildTask` to create a child task interactively
4. Test visualization commands to see if parent relationships are preserved

### Migration Testing (Existing Databases)

If you have existing task databases, the migration should happen automatically:

1. **Backup your existing databases** (important!)
   ```bash
   cp ~/.local/share/nvim/.personal-tasks.db ~/.local/share/nvim/.personal-tasks.db.backup
   cp ~/.local/share/nvim/.work-tasks.db ~/.local/share/nvim/.work-tasks.db.backup
   ```

2. **Save a notes file** with tasks - this will trigger the migration
   - The system will detect missing `parent_id` column
   - Add the nullable column and its index automatically 
   - Show notification: "🔄 Running database migration: Adding parent_id column"
   - Confirm success: "✅ Database migration completed: parent_id column and index added"

3. **Verify migration worked**:
   ```bash
   sqlite3 ~/.local/share/nvim/.personal-tasks.db
   .schema task_events
   .schema
   ```
   You should see `parent_id TEXT` in the table schema and `idx_parent_id` index
   
   ```sql
   -- Check existing tasks have NULL parent_id
   SELECT task_id, parent_id FROM task_events LIMIT 5;
   ```
   Old tasks will show NULL in parent_id column

4. **Test new functionality**:
   - Create parent tasks with `:ZkNewTask`
   - Create child tasks with `:ZkNewChildTask` 
   - View hierarchy with `:ZkTaskHierarchy personal <uuid>`

### Interactive Testing

1. **Create Parent Task**: Use `<leader>nT` to create a new parent task
2. **Create Child Task**: Use `<leader>nC` and enter the parent task UUID
3. **View Hierarchy**: Use `:ZkTaskHierarchy personal <parent_uuid>` to see the tree
4. **Query Functions**: Test in Lua with:
   ```lua
   -- Get child tasks
   local children = require('notes').get_child_tasks('personal', 'parent-uuid-here')
   
   -- Get parent task
   local parent = require('notes').get_parent_task('personal', 'child-uuid-here')
   
   -- Show full hierarchy
   require('notes').show_task_hierarchy('personal', 'root-uuid-here')
   ```

### Database Verification

Check your task database (e.g., `~/.local/share/nvim/.personal-tasks.db`) to verify:

```sql
-- Check parent_id column exists
PRAGMA table_info(task_events);

-- View tasks with parent relationships
SELECT task_id, parent_id, task_text, state, timestamp 
FROM task_events 
WHERE parent_id IS NOT NULL 
ORDER BY timestamp DESC;

-- View full hierarchy for a specific parent
WITH RECURSIVE task_tree AS (
  -- Base case: root task
  SELECT task_id, parent_id, task_text, 0 as level
  FROM task_events 
  WHERE task_id = 'your-root-uuid-here'
  
  UNION ALL
  
  -- Recursive case: children
  SELECT te.task_id, te.parent_id, te.task_text, tt.level + 1
  FROM task_events te
  JOIN task_tree tt ON te.parent_id = tt.task_id
)
SELECT * FROM task_tree ORDER BY level, task_id;
```

## Expected Database Structure

```sql
-- task_events table after migration:
CREATE TABLE task_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    task_text TEXT,
    state TEXT,
    journal_file TEXT,
    parent_id TEXT,  -- NEW: Nullable column for parent task UUID
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sample data after migration:
-- Old tasks: parent_id = NULL
-- New tasks: parent_id = 'parent-uuid' or NULL

-- Task states: CREATED, FINISHED, IN_PROGRESS, CARRIED_OVER
-- Event types: task_created, task_updated, task_completed, task_reopened, task_carried_over
```

## Usage Examples

### Creating Parent-Child Tasks Manually
```markdown
- [ ] Parent task [ ](task://parent-uuid)
  - [ ] Child task 1 [ ](task://child1-uuid?parent=parent-uuid)
  - [ ] Child task 2 [ ](task://child2-uuid?parent=parent-uuid)
```

### Using Commands
```vim
:ZkNewTask                         " Create standalone task
:ZkNewTask parent-uuid-here        " Create task with specified parent
:ZkNewChildTask                    " Interactive child task creation with picker
```

#### ZkNewChildTask Picker Features
- **Smart context detection** - Auto-detects personal/work tasks based on current file
- **Recent tasks** - Shows tasks from last 30 days that aren't completed
- **Easy identification** - Display format: `12ab34cd 🚀 Task name preview...`
  - Truncated UUID (first 8 chars) 
  - State emoji (📝 Created, 🚀 In Progress)
  - Task name preview (50 chars max)
- **Subtle positioning** - Small picker aligned to bottom-left corner
- **Auto-insertion** - Selected parent UUID automatically inserted in child task

Example picker appearance:
```
┌─ Select Parent Task ──────────────────────────┐
│ > abc12345 📝 Implement user authentication   │
│   def67890 🚀 Create API endpoints            │
│   ghi23456 📝 Add database migrations         │
│   jkl78901 🚀 Setup testing framework         │
└───────────────────────────────────────────────┘
```
