if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
function! searchhl_ember#put_hl() abort "{{{
  call s:prepare_hl()
  let [len, i] = [len(g:searchhl_ember#colors), 0]
  while i < len
    let hist = histget('search', -1 * (i+2))
    call add(w:SearchhlEmber_histMIds, [hist, matchadd('SearchhlEmber_'. i, hist, -1 * i)])
    let i += 1
  endwhile
endfunc
"}}}
function! s:prepare_hl() abort "{{{
  let [len, i] = [len(g:searchhl_ember#colors), 0]
  while i < len
    if g:searchhl_ember#colors[i] =~ '|'
      throw 'searchhl-ember: dangerous char `|` cannot be contained in g:searchhl_ember#colors'
    end
    exe 'highlight SearchhlEmber_'. i. ' '. g:searchhl_ember#colors[i]
    let i += 1
  endwhile
endfunc
"}}}

function! searchhl_ember#is_wornhl() abort "{{{
  if len(w:SearchhlEmber_histMIds) != len(g:searchhl_ember#colors)
    return 1
  end
  let i = -2
  for [hist, _] in w:SearchhlEmber_histMIds
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
