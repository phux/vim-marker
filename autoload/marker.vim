let s:marker_stack = []
let s:marker_stack_pos = 0

function! marker#ToggleMark()
  let l:currentFile = expand('%:p')
  if l:currentFile ==# ''
    if &buftype ==# 'quickfix'
      call marker#DeleteFromQuickfix()
    endif
    return
  endif

  let l:pos = getpos('.')

  let l:index = 0
  for position in s:marker_stack
    if position['file'] == l:currentFile && position['cursor'][1] == l:pos[1]
      call marker#Remove(l:index)
      return
    endif
    let l:index += 1
  endfor

  let l:text = getline('.')
  if l:text ==# ''
    let l:text = ' '
  endif

  let l:qfix = l:currentFile . ':' . l:pos[1] . ':' . l:text
  call add(s:marker_stack, {'file': l:currentFile, 'cursor': l:pos, 'text': l:text, 'qfix': l:qfix})
  let s:marker_stack_pos = len(s:marker_stack) - 1
  let s:qf_stale = 1
  echo 'mark set'

  call marker#Persist()

  if marker#isQuickfixOpen()
    :cclose
  endif
endfunction

function! marker#NextMark()
  if s:marker_stack == []
    echo 'no marks set yet'
    return
  endif

  let s:marker_stack_pos += 1
  if s:marker_stack_pos == len(s:marker_stack)
    let s:marker_stack_pos = 0
  endif

  call marker#GoToMark()
endfunction

function! marker#PrevMark()
  if s:marker_stack == []
    echo 'no marks set yet'
    return
  endif

  let s:marker_stack_pos -= 1
  if s:marker_stack_pos < 0
    let s:marker_stack_pos = len(s:marker_stack) - 1
  endif

  call marker#GoToMark()
endfunction

function! marker#GoToMark()
  let l:marker = s:marker_stack[s:marker_stack_pos]
  if expand('%:p') != l:marker['file']
    exec ':e '.l:marker['file']
  endif

  exec ':'.l:marker['cursor'][1]
endfunction

function! marker#ToggleQuickfix()
  if marker#isQuickfixOpen()
    :cclose
    return
  endif

  call marker#RefreshQuickfix()

  :copen
endfunction

function! marker#RefreshQuickfix()
  if !s:qf_stale
    return
  endif

  call setqflist([])
  for position in s:marker_stack
    caddexpr position["qfix"]
  endfor

  let s:qf_stale = 0
endfunction

function! marker#LoadStackFromFile()
  let l:file = marker#getPersistenceFile()
  if !filereadable(l:file)
    return
  endif

  let serialized = readfile(l:file)[0]
  exec 'let s:marker_stack = ' . serialized
  let s:qf_stale = 1
endfunction

function! marker#Persist()
  call writefile([string(s:marker_stack)], marker#getPersistenceFile())
endfunction

""
" Clears all markers for current working directory.
" @public
function! marker#ResetMarkers() abort
  silent exec ':!rm '.marker#getPersistenceFile()
  let s:marker_stack = []
  let s:marker_stack_pos = 0
  let s:qf_stale = 1
  call marker#RefreshQuickfix()
endfunction

function! marker#DeleteFromQuickfix()
  call marker#Remove(line('.')-1)
endfunction

function! marker#Remove(index)
  call remove(s:marker_stack, a:index)
  echo 'mark removed'

  if s:marker_stack_pos > (len(s:marker_stack) - 1)
    let s:marker_stack_pos = len(s:marker_stack) - 1
  endif

  call marker#Persist()

  let s:qf_stale = 1
  if marker#isQuickfixOpen()
    if len(s:marker_stack) > 0
      call marker#RefreshQuickfix()
    else
      :cclose
    endif
  endif
endfunction

function! marker#isQuickfixOpen()
  return [] != filter(range(1, winnr('$')), 'getwinvar(v:val, "&ft") ==# "qf"')
endfunction

function! marker#getPersistenceFile()
  return g:MarkerPersistenceDir.'/'. substitute(getcwd().'.txt', '/', '_', 'g')
endfunction
