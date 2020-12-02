if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_searchhl_ember')| finish| endif| let g:loaded_searchhl_ember = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:searchhl_ember#enable_with_hlsearch = get(g:, 'searchhl_ember#enable_with_hlsearch', 0)
let g:searchhl_ember#colors = exists('g:searchhl_ember#colors') ? g:searchhl_ember#colors :
  \ ['guibg=#A5A500 guifg=Black  ctermbg=142 ctermfg=16', 'guibg=#656600 guifg=gray66  ctermbg=58 ctermfg=247']

command! -bang SearchhlEmberEnable   let &hlsearch = &hlsearch | call s:enable(<bang>0)
command! -bang SearchhlEmberDisable  call s:disable(<bang>0)

aug searchhl_ember
  au!
  au VimEnter *   let w:SearchhlEmber_histMIds = []
  au WinEnter *   call s:Init()
  au CmdwinLeave,CursorHold * call s:RefreshAll()
  au CursorMoved *  call s:refreshall_by_mode()
  if exists('##CmdlineLeave')
    au CmdlineLeave * call s:RefreshAll()
  end
aug END

let s:manual_enabling = 0
let s:hist_at_cleared = ''
function! s:Init() abort "{{{
  let prerequisite = s:hl_common_prerequisite()
  if exists('w:SearchhlEmber_histMIds') | return s:Refresh(prerequisite) | endif
  let w:SearchhlEmber_histMIds = []
  if !prerequisite.is_enabled
    let s:manual_enabling = 0
    return
  elseif !(prerequisite.is_clear_ineffective && searchhl_ember#is_wornhl())
    return
  end
  let s:hist_at_cleared = ''
  call searchhl_ember#put_hl()
endfunc
"}}}
function! s:Refresh(prerequisite) abort "{{{
  if !exists('w:SearchhlEmber_histMIds')
    return
  elseif !a:prerequisite.is_enabled
    let s:manual_enabling = 0
    call s:clear_hl()
    return
  elseif  !a:prerequisite.is_clear_ineffective
    call s:clear_hl()
    return
  elseif !searchhl_ember#is_wornhl()
    return
  end
  call s:clear_hl()
  let s:hist_at_cleared = ''
  call searchhl_ember#put_hl()
endfunc
"}}}
function! s:RefreshAll() abort "{{{
  let prerequisite = s:hl_common_prerequisite()
  let winnr = winnr()
  try
    call s:refreshall_inner(prerequisite)
  catch
    let [s:manual_enabling, g:searchhl_ember#enable_with_hlsearch] = [0, 0]
    echoerr printf("searchhl-ember: %s    %s", v:throwpoint, v:exception)
  finally
    noa keepj exe winnr. 'wincmd w'
  endtry
endfunc
"}}}
function! s:ClearAll() abort "{{{
  let s:hist_at_cleared = histget('search', -1)
  let winnr = winnr()
  noa keepj windo call s:clear_hl()
  noa keepj exe winnr. 'wincmd w'
endfunc
"}}}

function! s:clear_hl() "{{{
  for [_, mId] in w:SearchhlEmber_histMIds
    call matchdelete(mId)
  endfor
  let w:SearchhlEmber_histMIds = []
endfunc
"}}}

function! s:hl_common_prerequisite() abort "{{{
  let is_enabled = (s:manual_enabling || g:searchhl_ember#enable_with_hlsearch) && &hlsearch && get(v:, 'hlsearch', 1)
  return !is_enabled ? {'is_enabled': 0} : {'is_enabled': 1,
    \ 'is_clear_ineffective': s:hist_at_cleared=='' || s:hist_at_cleared !=# histget('search', -1)}
endfunc
"}}}
if exists('*win_execute')
  function! s:refreshall_inner(prerequisite) abort "{{{
    let i = winnr('$')
    while i > 0
      call win_execute(win_getid(i), 'call s:Refresh(a:prerequisite)')
      let i -= 1
    endwhile
  endfunc "}}}
  function! s:refreshall_by_mode() abort "{{{
    return mode() =~# "[nvV\<C-v>]" && s:RefreshAll()
  endfunc "}}}
else
  function! s:refreshall_inner(prerequisite) abort "{{{
    noa keepj windo call s:Refresh(a:prerequisite)
  endfunc "}}}
  function! s:refreshall_by_mode() abort "{{{
    return mode() ==# "n" && s:RefreshAll()
  endfunc "}}}
end
function! s:enable(persist) abort "{{{
  if a:persist | let g:searchhl_ember#enable_with_hlsearch = 1 | endif
  let s:hist_at_cleared = ''
  let s:manual_enabling = 1
  call s:RefreshAll()
endfunc
"}}}
function! s:disable(persist) abort "{{{
  if a:persist | let g:searchhl_ember#enable_with_hlsearch = 0 | endif
  let s:manual_enabling = 0
  call s:ClearAll()
endfunc
"}}}
"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
