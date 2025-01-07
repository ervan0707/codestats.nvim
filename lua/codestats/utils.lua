local M = {}
local config = require('codestats.config')

-- Calculate XP based on buffer changes
function M.calculate_xp()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get buffer changes
  local changes = vim.b[bufnr].codestats_changes or 0
  vim.b[bufnr].codestats_changes = 0

  return changes
end

-- Check if filetype should be tracked
function M.should_track_filetype(ft)
  if not ft or ft == '' then
    return false
  end

  for _, excluded in ipairs(config.options.excluded_filetypes) do
    if ft == excluded then
      return false
    end
  end

  return true
end

-- Helper function to get ISO 8601 timestamp with timezone
function M.get_iso_timestamp()
  -- Get current time
  local ts = os.time()
  -- Convert to ISO 8601 format with timezone
  local tz_offset = os.date('%z', ts)
  -- Format like "2016-04-24T01:43:56+12:00"
  local formatted = os.date('%Y-%m-%dT%H:%M:%S', ts)
  -- Insert colon in timezone offset ("+0800" -> "+08:00")
  local tz_formatted = string.format('%s:%s', string.sub(tz_offset, 1, 3), string.sub(tz_offset, 4))
  return formatted .. tz_formatted
end

function M.normalize_filetype(ft)
  -- Map filetypes to CodeStats language names
  local ft_map = {
    -- Common Programming Languages
    ['c'] = 'C',
    ['cpp'] = 'C++',
    ['c++'] = 'C++',
    ['cs'] = 'C#',
    ['java'] = 'Java',
    ['py'] = 'Python',
    ['python'] = 'Python',
    ['rb'] = 'Ruby',
    ['ruby'] = 'Ruby',
    ['php'] = 'PHP',
    ['go'] = 'Go',
    ['golang'] = 'Go',
    ['rs'] = 'Rust',
    ['rust'] = 'Rust',
    ['swift'] = 'Swift',
    ['kotlin'] = 'Kotlin',
    ['scala'] = 'Scala',

    -- Web Technologies
    ['js'] = 'JavaScript',
    ['javascript'] = 'JavaScript',
    ['javascript.jsx'] = 'JavaScript',
    ['ts'] = 'TypeScript',
    ['typescript'] = 'TypeScript',
    ['typescript.tsx'] = 'TypeScript',
    ['jsx'] = 'JavaScript',
    ['tsx'] = 'TypeScript',
    ['html'] = 'HTML',
    ['css'] = 'CSS',
    ['scss'] = 'SCSS',
    ['sass'] = 'Sass',
    ['less'] = 'Less',
    ['vue'] = 'Vue',
    ['svelte'] = 'Svelte',

    -- Functional Languages
    ['hs'] = 'Haskell',
    ['haskell'] = 'Haskell',
    ['ex'] = 'Elixir',
    ['exs'] = 'Elixir',
    ['eex'] = 'EEx',
    ['heex'] = 'HEEx',
    ['leex'] = 'LEEx',
    ['erl'] = 'Erlang',
    ['erlang'] = 'Erlang',
    ['fs'] = 'F#',
    ['fsharp'] = 'F#',
    ['ml'] = 'OCaml',
    ['ocaml'] = 'OCaml',
    ['elm'] = 'Elm',
    ['clj'] = 'Clojure',
    ['clojure'] = 'Clojure',

    -- Shell and System
    ['sh'] = 'Shell',
    ['bash'] = 'Bash',
    ['zsh'] = 'Zsh',
    ['fish'] = 'Fish',
    ['ps1'] = 'PowerShell',
    ['powershell'] = 'PowerShell',
    ['bat'] = 'Batch',
    ['cmd'] = 'Batch',

    -- Data and Config Languages
    ['json'] = 'JSON',
    ['yaml'] = 'YAML',
    ['yml'] = 'YAML',
    ['toml'] = 'TOML',
    ['xml'] = 'XML',
    ['sql'] = 'SQL',
    ['graphql'] = 'GraphQL',
    ['ini'] = 'INI',

    -- Documentation and Markup
    ['md'] = 'Markdown',
    ['markdown'] = 'Markdown',
    ['tex'] = 'TeX',
    ['latex'] = 'LaTeX',
    ['rst'] = 'reStructuredText',
    ['asciidoc'] = 'AsciiDoc',
    ['adoc'] = 'AsciiDoc',

    -- Editor Specific
    ['vim'] = 'VimL',
    ['nvim'] = 'VimL',
    ['lua'] = 'Lua',
    ['el'] = 'Emacs Lisp',
    ['elisp'] = 'Emacs Lisp',

    -- Mobile Development
    ['dart'] = 'Dart',
    ['flutter'] = 'Dart',
    ['objc'] = 'Objective-C',
    ['objcpp'] = 'Objective-C++',

    -- Infrastructure and DevOps
    ['dockerfile'] = 'Dockerfile',
    ['terraform'] = 'HCL',
    ['tf'] = 'HCL',
    ['hcl'] = 'HCL',
    ['ansible'] = 'YAML',
    ['k8s'] = 'YAML',
    ['helm'] = 'YAML',

    -- Other Languages
    ['r'] = 'R',
    ['julia'] = 'Julia',
    ['jl'] = 'Julia',
    ['perl'] = 'Perl',
    ['pl'] = 'Perl',
    ['nim'] = 'Nim',
    ['d'] = 'D',
    ['crystal'] = 'Crystal',
    ['cr'] = 'Crystal',
    ['zig'] = 'Zig',
    ['v'] = 'V',
    ['vlang'] = 'V',
    ['groovy'] = 'Groovy',
    ['matlab'] = 'MATLAB',
    ['octave'] = 'Octave',
    ['pascal'] = 'Pascal',
    ['fortran'] = 'Fortran',
    ['cobol'] = 'COBOL',
    ['ada'] = 'Ada',
    ['solidity'] = 'Solidity',
    ['sol'] = 'Solidity',

    -- Template Languages
    ['j2'] = 'Jinja2',
    ['jinja'] = 'Jinja2',
    ['liquid'] = 'Liquid',
    ['mustache'] = 'Mustache',
    ['handlebars'] = 'Handlebars',
    ['hbs'] = 'Handlebars',

    -- Test Files
    ['spec.js'] = 'JavaScript',
    ['test.js'] = 'JavaScript',
    ['spec.ts'] = 'TypeScript',
    ['test.ts'] = 'TypeScript',
    ['spec.rb'] = 'Ruby',
    ['test.rb'] = 'Ruby',
  }

  -- If we have a direct mapping, use it
  if ft_map[ft] then
    return ft_map[ft]
  end

  -- Handle compound filetypes (e.g., 'javascript.jsx')
  local base_ft = ft:match('^([^%.]+)')
  if base_ft and ft_map[base_ft] then
    return ft_map[base_ft]
  end

  -- Default: capitalize first letter if no mapping exists
  return ft:gsub('^%l', string.upper)
end

return M
