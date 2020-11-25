if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_shadowing_hlsearch')| finish| endif| let g:loaded_shadowing_hlsearch = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:shadowing_hlsearch#enable_with_hlsearch = get(g:, 'shadowing_hlsearch#enable_with_hlsearch', 0)
let g:shadowing_hlsearch#colors = exists('g:shadowing_hlsearch#colors') ? g:shadowing_hlsearch#colors :
  \ ['guibg=#A5A500 guifg=Black  ctermbg=142 ctermfg=16', 'guibg=#656600 guifg=gray66  ctermbg=58 ctermfg=247']

noremap <Plug>(shadowing-hlsearch#clear-hl)   :<C-u>ShadowinghlsDisable<CR>
noremap <Plug>(shadowing-hlsearch#refresh)   :<C-u>call <SID>RefreshAll()<CR>

command! -bang ShadowinghlsEnable   let &hlsearch = &hlsearch | call s:enable(<bang>0)
command! -bang ShadowinghlsDisable  call s:disable(<bang>0)

aug shadowing_hlsearch
  au!
  au VimEnter *   let w:shadowingHLS_histMIds = []
  au WinEnter *   call s:Init()
  au CmdwinLeave,CursorHold *  call s:RefreshAll()
  if exists('##CmdlineLeave')
    au CmdlineLeave * call s:RefreshAll()
  end
aug END

let s:manual_enabling = 0
let s:hist_at_cleared = ''
function! s:Init() abort "{{{
  if exists('w:shadowingHLS_histMIds') | return s:Refresh() | endif
  let w:shadowingHLS_histMIds = []
  if !((s:manual_enabling || g:shadowing_hlsearch#enable_with_hlsearch) && &hlsearch && get(v:, 'hlsearch', 1))
    let s:manual_enabling = 0
    return
  elseif !(s:is_clear_ineffective() && shadowing_hlsearch#is_wornhl())
    return
  end
  let s:hist_at_cleared = ''
  call shadowing_hlsearch#put_hl()
endfunc
"}}}
function! s:Refresh() abort "{{{
  if !exists('w:shadowingHLS_histMIds')
    return
  elseif !((s:manual_enabling || g:shadowing_hlsearch#enable_with_hlsearch) && &hlsearch && get(v:, 'hlsearch', 1))
    let s:manual_enabling = 0
    call s:clear_hl()
    return
  elseif  !s:is_clear_ineffective()
    call s:clear_hl()
    return
  elseif !shadowing_hlsearch#is_wornhl()
    return
  end
  call s:clear_hl()
  let s:hist_at_cleared = ''
  call shadowing_hlsearch#put_hl()
endfunc
"}}}
function! s:RefreshAll() abort "{{{
  let winnr = winnr()
  try
    noa keepj windo call s:Refresh()
  catch
    let [s:manual_enabling, shadowing_hlsearch#enable_with_hlsearch] = [0, 0]
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
function! s:enable(persist) abort "{{{
  if a:persist | let g:shadowing_hlsearch#enable_with_hlsearch = 1 | endif
  let s:hist_at_cleared = ''
  let s:manual_enabling = 1
  call s:RefreshAll()
endfunc
"}}}
function! s:disable(persist) abort "{{{
  if a:persist | let g:shadowing_hlsearch#enable_with_hlsearch = 0 | endif
  let s:manual_enabling = 0
  call s:ClearAll()
endfunc
"}}}
"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
