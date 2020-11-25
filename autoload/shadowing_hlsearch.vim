if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
function! shadowing_hlsearch#put_hl() abort "{{{
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

function! shadowing_hlsearch#is_wornhl() abort "{{{
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
