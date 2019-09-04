""
" @section Introduction, intro
" vim-marker provides a custom marker stack, persistent per working directory.

if !exists('g:MarkerPersistenceDir')
  ""
  " Path to store the marks. Will be created if doesn't exist. Default: $XDG_DATA_HOME/vim-marker
  let g:MarkerPersistenceDir = $XDG_DATA_HOME . '/vim-marker'

  if !isdirectory(g:MarkerPersistenceDir)
    exec ':!mkdir -p '.g:MarkerPersistenceDir
  endif
endif

if !exists('g:MarkerEnableMappings')
  ""
  " Set to 0 to disable default mappings. Default: 1
  let g:MarkerEnableMappings = 1
endif

if g:MarkerEnableMappings
  if !exists('g:MarkerToggleMarkMapping')
    ""
    " Mapping to add or remove marker at current cursor position.
    " Also works in the quickfix window.
    " Default: <m-m>
    let g:MarkerToggleMarkMapping = '<m-m>'
  endif

  if !exists('g:MarkerNextMarkMapping')
    ""
    " Mapping for jumping to next mark. Default: <m-j>
    let g:MarkerNextMarkMapping = '<m-j>'
  endif

  if !exists('g:MarkerPrevMarkMapping')
    ""
    " Mapping for jumping to previous mark. Default: <m-k>
    let g:MarkerPrevMarkMapping = '<m-k>'
  endif

  if !exists('g:MarkerQuickfixToggleMapping')
    ""
    " Toggle quickfix window with current marks populated. Default: <m-;>
    let g:MarkerQuickfixToggleMapping = '<m-;>'
  endif

  exec 'nnoremap '.g:MarkerToggleMarkMapping.' :call marker#ToggleMark()<cr>'
  exec 'nnoremap '.g:MarkerNextMarkMapping.' :call marker#NextMark()<cr>'
  exec 'nnoremap '.g:MarkerPrevMarkMapping.' :call marker#PrevMark()<cr>'
  exec 'nnoremap '.g:MarkerQuickfixToggleMapping.' :call marker#ToggleQuickfix()<cr>'
endif

call marker#LoadStackFromFile()
