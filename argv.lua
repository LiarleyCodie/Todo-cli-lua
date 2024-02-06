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
    '--one',
    '-h'
  },
  create = {
    '-t',
    '-d',
    '-c',
    '--title',
    '--description',
    '--completed',
    '-h',
  },
  clear = {
    '-h'
  },
  check = {
    '-h'
  },
  remove = {
    '-h'
  }
}

local flagsMethods = {
  list = {
    help = function()
      print('- when called without arguments, list all actually registered tasks')
    end
  }
}

for i, currentUserArg in ipairs(arg) do
  if currentUserArg == '-h' or currentUserArg == '--help' then
    print('Available Commands:\n')
    print('create' .. '\t' .. 'usage: create -t ')
  end

  for j, currentValidArg in ipairs(validArguments) do
    if currentUserArg == currentValidArg then
        
      break
    else
      print('[ Invalid argument ]')
    end
  end
end
