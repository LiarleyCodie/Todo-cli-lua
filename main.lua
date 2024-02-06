local lfs = require('lfs')
local json = require('jsonlua.json')

local fpath = lfs.currentdir() .. '/tasks.json'

--- @param filepath string
--- @return table
local function readJson(filepath)
  local file = io.open(filepath, 'r')

  if file then
    local content = file:read('*a')
    file:close()

    return json.decode(content)
  end

  return {}
end

--- @param filepath string
--- @param content table
local function saveJson(filepath, content)
  if not lfs.attributes(filepath) then
    local file = io.open(filepath, 'w')
    if file then
      file:write(json.encode({}))
      file:close()
    end
  end

  local file = io.open(filepath, 'w')

  if file then
    file:write(json.encode(content))
    file:close()
  end
end

local Todo = {
  tasks = readJson(fpath)
}

-- print cli title
local function printTitle()
  print('\n========== TODO MANAGER ==========\n')
end

--- print just one task
--- @param task table { id: integer, title: string, description: string, status: string, completed: boolean }
local function printOneTask(task)
  local currentTaskStatus = task.completed and 'Done' or 'in progress'

  print('  [Task]:')
  print(string.format('  - [Title]: %s', task.title))
  print(string.format('  - [Id]: %d', task.id))
  print(string.format('  - [Description]: %s', task.description))
  print(string.format('  - [Status]: %s\n', currentTaskStatus))
end

--- print all task at once
--- @param tasks table tasks array
--- @param printFunc function the function that will print each task
local function printAllTasks(tasks, printFunc)
  tasks = tasks or { tasks = {} }

  if printFunc == nil then return end

  local totalOfTasks = #tasks
  local completedTasks = 0

  if (totalOfTasks ~= 0) then
    for _, task in ipairs(tasks) do
      if task.completed then
        completedTasks = completedTasks + 1
      end
    end
  end

  print(string.format('[All Tasks]: %d of %d completed\n', completedTasks, totalOfTasks))

  if (totalOfTasks ~= 0) then
    for _, task in ipairs(tasks) do
      printFunc(task)
    end
  else
    print('- No tasks have been registered yet! - ')
  end
end

--- @param text string
--- @return string
local function trim(text)
  local str = text:gsub('^%s*(.-)%s*$', '%1')
  return str
end

---create a task object
---@param title string
---@param description string
---@param completed boolean
---@param id integer
---@return table
local function CreateOneTask(title, description, completed, id)
  local incorrectFields = {}

  if trim(title) == '' then
    table.insert(incorrectFields, 'title')
  end
  if trim(description) == '' then
    table.insert(incorrectFields, 'description')
  end

  local incorrectFieldsLength = #incorrectFields
  if incorrectFieldsLength ~= 0 then
    print(string.format('! The following fields are empty: %s !', table.concat(incorrectFields, ', ')))
  else
    local status = completed and 'done' or 'in progress'

    return {
      id = id,
      title = title,
      description = description,
      status = status,
      completed = completed
    }
  end
end

---@param taskInArrayIndex integer
local function removeOneTask(taskInArrayIndex, tasks)
  table.remove(tasks, taskInArrayIndex)
end

--- todo manager print all tasks call method
---@param self table
---@param printAllTasksFunc function print all tasks method
---@param printFunc function print one task method
Todo.listAll = function(self, printAllTasksFunc, printFunc)
  printAllTasksFunc(self.tasks, printFunc)
end

--- Todo manager print one task call method
--- @param self table
--- @param printFunc function print one task method
--- @param id integer task id
Todo.listOne = function(self, printFunc, id)
  for _, task in ipairs(self.tasks) do
    if task.id == id then
      printFunc(task)
      break
    end
  end
end

--- Todo manager create one call method
---@param self table
---@param createFunc function create one task method
Todo.createOne = function(self, createFunc)
  local id = #self.tasks + 1
  local task = createFunc('Nova task', 'Descriçao formosa', false, id)

  if task then
    table.insert(self.tasks, task)
    print('! [Task Added] !')
  end
end

---Todo manager toggle an specific task completed status to true (if false) or false (if true)
---@param self table
---@param id integer task id
Todo.toggleCompleted = function(self, id)
  for _, task in ipairs(self.tasks) do
    if task.id == id then
      task.completed = not task.completed
      local newStatus = task.completed and 'done' or 'in progress'
      task.status = newStatus
      break
    end
  end
end

--- todo manager remove a specific task by id call method
---@param self table
---@param id integer
---@param removeOneTaskFunc function
Todo.removeOne = function(self, id, removeOneTaskFunc)
  for taskInArrayIndex, task in ipairs(self.tasks) do
    if task.id == id then
      removeOneTaskFunc(taskInArrayIndex, self.tasks)
      print('! [Task Removed] !')
      break
    end
  end
end

Todo.clearTasks = function(self)
  self.tasks = {}
end

printTitle()

-- Todo:listAll(printAllTasks, printOneTask)
-- Todo:createOne(CreateOneTask)
-- Todo:listAll(printAllTasks, printOneTask)

-- saveJson(fpath, Todo.tasks)

-- Todo:listOne(printOneTask, 2)
-- Todo:toggleCompleted(1)
-- Todo:listOne(printOneTask, 2)

-- Todo:removeOne(1, removeOneTask)
-- Todo:listAll(printAllTasks, printOneTask)

-- Todo:clearTasks()
-- Todo:listAll(printAllTasks, printOneTask)

for i, currentArg in ipairs(arg) do
  print(i, currentArg)
end

local validArguments = {
  'create', -- create <-t 'name'> <-d 'fazer x coisa'> [-c done] 
  'list',   -- list --one <id>
  'clear',  
  'check',  -- check <id>
  'remove'  -- remove <id>
}

local validFlags = {
  list = {
    '-o',
    '--one'
  },
  create = {
    '-t',
    '-d',
    '-c',
    '--title',
    '--description',
    '--completed'
  },
}
