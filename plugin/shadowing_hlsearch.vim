if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_shadowing_hlsearch')| finish| endif| let g:loaded_shadowing_hlsearch = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:shadowing_hlsearch#enable = exists('g:shadowing_hlsearch#enable') ? g:shadowing_hlsearch#enable : 0
let g:shadowing_hlsearch#colors = exists('g:shadowing_hlsearch#colors') ? g:shadowing_hlsearch#colors :
  \ ['guibg=#A5A500 guifg=Black  ctermbg=142 ctermfg=16', 'guibg=#656600 guifg=gray66  ctermbg=58 ctermfg=247']

noremap <Plug>(shadowing-hlsearch#clear-hl)   :<C-u>ShadowinghlsClearHL<CR>
noremap <Plug>(shadowing-hlsearch#refresh)   :<C-u>call <SID>RefreshAll()<CR>

command! ShadowinghlsClearHL  call s:ClearAll()
command! ShadowinghlsDisable  let g:shadowing_hlsearch#enable = 0 | call s:ClearAll()
command! ShadowinghlsEnable   let g:shadowing_hlsearch#enable = 1 | call s:RefreshAll()

aug shadowing_hlsearch
  au!
  au VimEnter,WinEnter * call s:Init()
  au CmdwinLeave,CursorHold *  call s:RefreshAll()
  if exists('##CmdlineLeave')
    au CmdlineLeave * call s:RefreshAll()
  end
aug END

let s:hist_at_cleared = ''
let g:shadowing_hlsearch#enable = 1
function! s:Init() abort "{{{
  if exists('w:shadowingHLS_histMIds') | return s:Refresh() | endif
  let w:shadowingHLS_histMIds = []
  if !(g:shadowing_hlsearch#enable && &hlsearch && get(v:, 'hlsearch', 1) && s:is_clear_ineffective() && s:is_wornhl())
    return
  end
  let s:hist_at_cleared = ''
  call s:put_hl()
endfunc
"}}}
function! s:RefreshAll() abort "{{{
  let winnr = winnr()
  try
    noa keepj windo call s:Refresh()
  catch
    let g:shadowing_hlsearch#enable = 0
    echoerr printf("shadowing-hlsearch: %s    %s", v:throwpoint, v:exception)
  finally
    exe winnr. 'wincmd w'
  endtry
endfunc
"}}}
function! s:ClearAll() abort "{{{
  let s:hist_at_cleared = histget('search', -1)
  let winnr = winnr()
  noa keepj windo call s:clear_hl()
  exe winnr. 'wincmd w'
endfunc
"}}}
function! s:Refresh() abort "{{{
  if !exists('w:shadowingHLS_histMIds')
    return
  elseif !(g:shadowing_hlsearch#enable && &hlsearch && get(v:, 'hlsearch', 1) && s:is_clear_ineffective())
    call s:clear_hl()
    return
  elseif !s:is_wornhl()
    return
  end
  let s:hist_at_cleared = ''
  call s:clear_hl()
  call s:put_hl()
endfunc
"}}}

function! s:put_hl() abort "{{{
  call s:prepare_hl()
  let [len, i] = [len(g:shadowing_hlsearch#colors), 0]
  while i < len
    let hist = histget('search', -1 * (i+2))
    call add(w:shadowingHLS_histMIds, [hist, matchadd('ShadowingHlSearch_'. i, hist, -1 * i)])
    let i += 1
  endwhile
endfunc
"}}}
function! s:prepare_hl() abort "{{{
  let [len, i] = [len(g:shadowing_hlsearch#colors), 0]
  while i < len
    if g:shadowing_hlsearch#colors[i] =~ '|'
      throw 'ShadowingHlSearch: dangerous char `|` cannot be contained in g:shadowing_hlsearch#colors'
    end
    exe 'highlight ShadowingHlSearch_'. i. ' '. g:shadowing_hlsearch#colors[i]
    let i += 1
  endwhile
endfunc
"}}}
function! s:clear_hl() "{{{
  for [_, mId] in w:shadowingHLS_histMIds
    call matchdelete(mId)
  endfor
  let w:shadowingHLS_histMIds = []
endfunc
"}}}

function! s:is_clear_ineffective() abort "{{{
  return s:hist_at_cleared=='' || s:hist_at_cleared !=# histget('search', -1)
endfunc
"}}}
function! s:is_wornhl() abort "{{{
  if len(w:shadowingHLS_histMIds) != len(g:shadowing_hlsearch#colors)
    return 1
  end
  let i = -2
  for [hist, _] in w:shadowingHLS_histMIds
    if hist !=# histget('search', i)
      return 1
    end
    let i -= 1
  endfor
  return 0
endfunc
"}}}
"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
