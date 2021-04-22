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
let b:MovingSandgrains = []
let b:StillSandgrains = []

let b:cursorPos = [0, 0]
let b:cursorChar = '*'

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
  let moving = 1

  if CanMoveDown(a:sandgrain)
    let a:sandgrain[1] += 1
  elseif CanMoveDownLeft(a:sandgrain)
    let a:sandgrain[1] += 1
    let a:sandgrain[0] -= 1
  elseif CanMoveDownRight(a:sandgrain)
    let a:sandgrain[1] += 1
    let a:sandgrain[0] += 1
  else
    let moving = 0
  endif

  return moving
endfunction

function! RenderSandgrain(sandgrain)
  let line = getline(a:sandgrain[1] + 2)
  let line = strcharpart(line, 0, a:sandgrain[0] + 1) . b:sandChar . strcharpart(line, a:sandgrain[0] + 2)
  call setline(a:sandgrain[1] + 2, line)
endfunction

function! CanMoveAgain(sandgrain)
  let lineIndex = a:sandgrain[1] + 3
  let columnIndex = a:sandgrain[0] + 2

  let downLeft  = nr2char(strgetchar(getline(lineIndex), columnIndex - 2))
  let downRight = nr2char(strgetchar(getline(lineIndex), columnIndex))

  return downLeft == ' ' || downRight == ' '
endfunction

function! MoveAndRenderSandgrains()
  let b:MovingSandgrains = sort(b:MovingSandgrains, {lhs, rhs -> lhs[1] < rhs[1]})
  
  let index = 0
  while index < len(b:StillSandgrains)
    if CanMoveAgain(b:StillSandgrains[index])
      let b:MovingSandgrains += [b:StillSandgrains[index]]
      call remove(b:StillSandgrains, index)
      continue
    else 
      call RenderSandgrain(b:StillSandgrains[index])
    endif

    let index += 1
  endwhile

  let index = 0
  while index < len(b:MovingSandgrains)
    if MoveDown(b:MovingSandgrains[index]) == 0
      call RenderSandgrain(b:MovingSandgrains[index])

      let b:StillSandgrains += [b:MovingSandgrains[index]]
      call remove(b:MovingSandgrains, index)
      continue
    else
      call RenderSandgrain(b:MovingSandgrains[index])
    endif

    let index += 1
  endwhile
endfunction

function! RenderSandgrains()
  let b:MovingSandgrains = sort(b:MovingSandgrains, {lhs, rhs -> lhs[1] < rhs[1]})
  
  for sandgrain in b:StillSandgrains
    call RenderSandgrain(sandgrain)
  endfor

  for sandgrain in b:MovingSandgrains
    call RenderSandgrain(sandgrain)
  endfor
endfunction

function! NotWithinBounds(pos)
  echo a:pos

  if a:pos[1] < 0 || a:pos[1] > b:boardHeight
    return 1
  elseif a:pos[0] < 1 || a:pos[0] > b:boardWidth
    return 1
  endif

  return 0
endfunction

function! AddSand()
  let b:MovingSandgrains = b:MovingSandgrains + [deepcopy(b:cursorPos)]
  call RenderSandgrain(b:MovingSandgrains[len(b:MovingSandgrains) - 1])
endfunction

function! RenderCursor()
  let line = getline(b:cursorPos[1] + 2)
  let line = strcharpart(line, 0, b:cursorPos[0] + 1) . b:cursorChar . strcharpart(line, b:cursorPos[0] + 2)
  call setline(b:cursorPos[1] + 2, line)
endfunction

function! GameTick(timer)
  call Clear()

  if b:paused == 0
    call MoveAndRenderSandgrains()
  else
    call RenderSandgrains()
  endif

  call RenderCursor()
endfunction

let b:paused = 1
function! PauseResume()
  if b:paused == 1
    let b:paused = 0
    call timer_stopall()
    call timer_start(100, 'GameTick', {'repeat' : -1})
  else
    let b:paused = 1
    call timer_stopall()
    call timer_start(100, 'GameTick', {'repeat' : -1})
  endif
endfunction

function! CursorDown()
  if NotWithinBounds([b:cursorPos[0], b:cursorPos[1] + 1])
    return
  endif

  let b:cursorPos[1] += 1
endfunction

function! CursorUp()
  if NotWithinBounds([b:cursorPos[0], b:cursorPos[1] - 1])
    return
  endif

  let b:cursorPos[1] -= 1
endfunction

function! CursorLeft()
  if NotWithinBounds([b:cursorPos[0] - 1, b:cursorPos[1]])
    return
  endif

  let b:cursorPos[0] -= 1
endfunction

function! CursorRight()
  if NotWithinBounds([b:cursorPos[0] + 1, b:cursorPos[1]])
    return
  endif

  let b:cursorPos[0] += 1
endfunction

call Clear()

augroup FallingSand
  autocmd!
  autocmd BufLeave *.fallingSand call timer_stopall() | let b:paused = 1
  autocmd BufEnter *.fallingSand let b:paused = 0     | call PauseResume()
augroup END

nnoremap <silent><buffer><C-r>    :call timer_stopall()<CR>:e!<CR>
nnoremap <silent><buffer><space>  :call PauseResume()<CR>
nnoremap <silent><buffer>i        :call AddSand()<CR>

nnoremap <silent><buffer>j        :call CursorDown()<CR>
nnoremap <silent><buffer>k        :call CursorUp()<CR>
nnoremap <silent><buffer>h        :call CursorLeft()<CR>
nnoremap <silent><buffer>l        :call CursorRight()<CR>
