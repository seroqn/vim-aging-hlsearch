" How to test:
" $ cd vim-searchhl-ember
" $ themis    # required "thinca/vim-themis"

let s:suite = themis#suite('vim-searchhl-ember')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:fn = s:scope.funcs('plugin/searchhl_ember.vim')
let s:sv = s:scope.vars('plugin/searchhl_ember.vim')
function! s:suite.before() abort
  set hlsearch
  doa searchhl_ember VimEnter
endfunc

function! s:suite.__put_hl__() abort
  let suite = themis#suite('put_hl_and_clear_hl')
  function! suite.when_history_is_empty() abort "{{{
    call searchhl_ember#put_hl()
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
  function! suite.when_history_is_not_empty() abort "{{{
    call histadd('search', 'abc')
    call histadd('search', 'def')
    call histadd('search', 'ghi')
    call searchhl_ember#put_hl()
    call s:assert.not_equals(w:SearchhlEmber_histMIds, []) " [['def', 4], ['abc', 5]]
  endfunc
  "}}}
  function! suite.clear_hl() abort "{{{
    call s:assert.not_equals(w:SearchhlEmber_histMIds, []) " [['def', 4], ['abc', 5]]
    call s:fn.clear_hl()
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
endfunc
function! s:suite.__prerequisite__() abort
  let suite = themis#suite('prerequisite')
  function! suite.is_enabled() abort " {{{
    let g:searchhl_ember#enable_with_hlsearch = 0
    let s:sv.manual_enabling = 0
    call s:assert.false(s:fn.is_enabled_et_is_clear_ineffective()[0], 'g:searchhl_ember#enable_with_hlsearch==0')

    let g:searchhl_ember#enable_with_hlsearch = 1
    let v:hlsearch = 0
    call s:assert.false(s:fn.is_enabled_et_is_clear_ineffective()[0], 'g:searchhl_ember#enable_with_hlsearch==1 && v:hlsearch==0')

    let g:searchhl_ember#enable_with_hlsearch = 0
    let s:sv.manual_enabling = 1
    let v:hlsearch = 1
    call s:assert.true(s:fn.is_enabled_et_is_clear_ineffective()[0], 's:manual_enabling==1 && v:hlsearch==1')

    let g:searchhl_ember#enable_with_hlsearch = 1
    let s:sv.manual_enabling = 0
    let v:hlsearch = 1
    call s:assert.true(s:fn.is_enabled_et_is_clear_ineffective()[0], 'g:searchhl_ember#enable_with_hlsearch==1 && v:hlsearch==1')
  endfunc
  "}}}
  function! suite.is_clear_ineffective() abort "{{{
    let g:searchhl_ember#enable_with_hlsearch = 1
    let v:hlsearch = 1

    let s:sv.hist_at_cleared = ''
    call s:assert.true(s:fn.is_enabled_et_is_clear_ineffective()[1], 's:hist_at_cleared==""')

    call histadd('search', 'jkl')
    let s:sv.hist_at_cleared = 'xyz'
    call s:assert.true(s:fn.is_enabled_et_is_clear_ineffective()[1], 'hist[-1]=="jkl" && s:hist_at_cleared=="xyz"')

    let s:sv.hist_at_cleared = 'jkl'
    call s:assert.false(s:fn.is_enabled_et_is_clear_ineffective()[1], 'hist[-1]=="jkl" && s:hist_at_cleared=="jkl"')
  endfunc
  "}}}
endfunc
function! s:suite.__Refresh__() abort
  let suite = themis#suite('Refresh')
  function! suite.is_not_enabled() abort "{{{
    call searchhl_ember#put_hl()
    call s:assert.not_equals(w:SearchhlEmber_histMIds, []) " [['ghi', 6], ['def', 7]]
    call s:fn.Refresh(0, 0)
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
  function! suite.is_not_clear_ineffective() abort "{{{
    call searchhl_ember#put_hl()
    call s:assert.not_equals(w:SearchhlEmber_histMIds, []) " [['ghi', 8], ['def', 9]]
    call s:fn.Refresh(1, 0)
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
  function! suite.is_wornhl() abort "{{{
    call searchhl_ember#put_hl()
    let save_histMIds = deepcopy(w:SearchhlEmber_histMIds)
    call s:fn.Refresh(1, 1)
    call s:assert.equals(w:SearchhlEmber_histMIds, save_histMIds) " [['ghi', 10], ['def', 11]]
    call histadd('search', 'mno')
    call s:fn.Refresh(1, 1)
    call s:assert.not_equals(w:SearchhlEmber_histMIds, save_histMIds) " [['jkl', 12], ['ghi', 13]]
  endfunc
  "}}}
endfunc
function! s:suite.__Init__() abort
  let suite = themis#suite('Init')
  function! suite.is_not_enabled() abort "{{{
    unlet! w:SearchhlEmber_histMIds
    call s:fn.Init(0, 0)
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
  function! suite.is_not_clear_ineffective() abort "{{{
    unlet! w:SearchhlEmber_histMIds
    call s:fn.Init(1, 0)
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
  function! suite.put_hl() abort "{{{
    unlet! w:SearchhlEmber_histMIds
    call s:fn.Init(1, 1)
    call s:assert.not_equals(w:SearchhlEmber_histMIds, []) " [['jkl', 12], ['ghi', 13]]
  endfunc
  "}}}
endfunc
function! s:suite.__ClearAll__() abort
  let suite = themis#suite('ClearAll')
  function! suite.when_clearall() abort "{{{
    let lasthist = histget('search', -1)
    call s:fn.ClearAll()
    call s:assert.equals(s:sv.hist_at_cleared, lasthist)
    call s:assert.equals(w:SearchhlEmber_histMIds, [])
  endfunc
  "}}}
endfunc
function! s:suite.__SearchhlEmberEnable__() abort
  let suite = themis#suite('SearchhlEmberEnable')
  function! suite.when_SearchhlEmberEnable() abort "{{{
    let v:hlsearch = 0
    SearchhlEmberEnable
    call s:assert.true(v:hlsearch)
    call s:assert.true(s:sv.manual_enabling)
    call s:assert.equal(s:sv.hist_at_cleared, '')
  endfunc
  "}}}
endfunc
