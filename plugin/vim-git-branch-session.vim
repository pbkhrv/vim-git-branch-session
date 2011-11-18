"
"
" Private methods
"
"
function! s:sub(str,pat,rep) abort
  " borrowed from fugitive.vim by tpope
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:get_current_git_branch() abort
  " http://stackoverflow.com/questions/2863756/is-there-a-single-git-command-to-get-the-current-tag-branch-and-commit
  let branch = s:sub(system('git describe --contains --all HEAD 2> /dev/null'),'\n$','')
  if empty(branch)
    throw 'Git branch is empty - are you in a git repo?'
  endif
  return branch
endfunction

function! s:make_file_name(project, branch) abort
  let base_path = '~/vim-sessions'
  if exists("g:BranchSession_base_path")
    let base_path = s:sub(g:BranchSession_session_base_path,'\/+$','')
  endif
  return base_path . '/' . a:project . '__' . a:branch . '.vim'
endfunction

function! s:load_session(project, branch)
  let file_name = s:make_file_name(a:project, a:branch)
  let glob_name = glob(file_name)

  if filereadable(glob_name)
    exe 'source ' . glob_name
  else
    throw 'No existing file found with name ' . file_name . '. A file will be created when you save current branch session or exit.' 
    return 0
  endif
endfunction

function! s:auto_save_branch_session()
  augroup BranchSessionAutosave
    au!
    au VimLeave * call SaveCurrentBranchSession()
  augroup end
endfunction

function! s:save_branch_session(project, branch) abort
  if !empty(a:project) && !empty(a:branch)
    exe 'mks! ' . s:make_file_name(a:project, a:branch)
  endif
endfunction

function! s:set_current_branch_session(project, branch) abort
  let g:BranchSession_project = a:project
  let g:BranchSession_branch = a:branch
endfunction

"
"
" Public methods
"
"
function! NewBranchSession(project) abort
  let branch = s:get_current_git_branch()
  call s:set_current_branch_session(a:project, branch)
  call SaveCurrentBranchSession()
  call s:auto_save_branch_session()
endfunction

function! LoadBranchSession(project) abort
  let branch = s:get_current_git_branch()

  " only load session if it's different from current
  if !exists("g:BranchSession_project") || !exists("g:BranchSession_branch") || g:BranchSession_project != a:project || g:BranchSession_branch != branch
    call s:load_session(a:project, branch)
  endif

  call s:set_current_branch_session(a:project, branch)
  call s:auto_save_branch_session()
endfunction

function! SaveCurrentBranchSession() abort
  if exists("g:BranchSession_project") && exists("g:BranchSession_branch")
    call s:save_branch_session(g:BranchSession_project, g:BranchSession_branch)
  endif
endfunction

