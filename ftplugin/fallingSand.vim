let b:boardHeight = 50
let b:boardWidth = 78

function! ClearBoard()
  let i = 1
  while i <= (b:boardWidth + 2)
    call setline(i, '')
    let i += 1
  endwhile
endfunction

let b:borderLine = ""
let i = 0
while i < b:boardWidth + 2
  let b:borderLine .= '-'
  let i += 1
endwhile


function! BorderLine(line)
  call setline(a:line, b:borderLine)
endfunction

let b:whitespace = ""
let i = 0
while i < b:boardWidth
  let b:whitespace .= ' '
  let i += 1
endwhile

let b:columnLine = '|' . b:whitespace. '|'

function! BorderColumns()
  let whitespace = ''

  let i = 0
  while i < (b:boardHeight)
    call setline(2 + i, b:columnLine)

    let i += 1
  endwhile
endfunction

function! Clear()
  call ClearBoard()
  call BorderLine(1)
  call BorderLine(b:boardHeight + 2)
  call BorderColumns()
endfunction

let b:sandChar = '#'
let b:sandgrains = []

function! CanMoveDown(sandgrain)
  let lineIndex = a:sandgrain[1] + 3
  let columnIndex = a:sandgrain[0] + 1

  let characterBelow = nr2char(strgetchar(getline(lineIndex), columnIndex))

  return characterBelow == ' '
endfunction

function! CanMoveDownLeft(sandgrain)
  let lineIndex = a:sandgrain[1] + 3
  let columnIndex = a:sandgrain[0]

  let characterBelow = nr2char(strgetchar(getline(lineIndex), columnIndex))

  return characterBelow == ' '
endfunction

function! CanMoveDownRight(sandgrain)
  let lineIndex = a:sandgrain[1] + 3
  let columnIndex = a:sandgrain[0] + 2

  let characterBelow = nr2char(strgetchar(getline(lineIndex), columnIndex))

  return characterBelow == ' '
endfunction

function! MoveDown(sandgrain)
  if CanMoveDown(a:sandgrain)
    let a:sandgrain[1] += 1
  elseif CanMoveDownLeft(a:sandgrain)
    let a:sandgrain[1] += 1
    let a:sandgrain[0] -= 1
  elseif CanMoveDownRight(a:sandgrain)
    let a:sandgrain[1] += 1
    let a:sandgrain[0] += 1
  endif
endfunction

function! RenderSandgrain(sandgrain)
  let line = getline(a:sandgrain[1] + 2)
  let line = strcharpart(line, 0, a:sandgrain[0] + 1) . b:sandChar . strcharpart(line, a:sandgrain[0] + 2)
  call setline(a:sandgrain[1] + 2, line)
endfunction

function! RenderSandgrains(timer)
  call Clear()

  let b:sandgrains = sort(b:sandgrains, {lhs, rhs -> lhs[1] < rhs[1]})

  for sandgrain in b:sandgrains
    call MoveDown(sandgrain)
    call RenderSandgrain(sandgrain)
  endfor
endfunction

augroup FallingSand
  autocmd!
  autocmd BufLeave *.fallingSand call timer_stopall() | let b:paused = 1
augroup END

call RenderSandgrains(0)
let b:paused = 1

function! PauseResume()
  if b:paused == 1
    let b:paused = 0
    call timer_start(20, 'RenderSandgrains', {'repeat' : -1})
  else
    let b:paused = 1
    call timer_stopall()
  endif
endfunction

function! NotWithinBounds(pos)
  if a:pos[1] <= 1 || a:pos[1] > b:boardHeight + 1
    return 1
  elseif a:pos[0] <= 1 || a:pos[0] > b:boardWidth + 1
    return 1
  endif

  return 0
endfunction

function! AddSand()
  if b:paused == 0
    return
  endif

  let cursorPos = getcurpos()

  if NotWithinBounds([cursorPos[2], cursorPos[1]]) == 1
    return
  endif

  let b:sandgrains = b:sandgrains + [[cursorPos[2] - 2, cursorPos[1] - 2]]
  call RenderSandgrain(b:sandgrains[len(b:sandgrains) - 1])
endfunction

nnoremap <buffer><C-r> :call timer_stopall()<CR>:e!<CR>
nnoremap <buffer><space> :call PauseResume()<CR>
nnoremap <buffer>i :call AddSand()<CR>
