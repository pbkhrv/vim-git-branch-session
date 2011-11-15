function! s:sub(str,pat,rep) abort
  " borrowed from fugitive.vim by tpope
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:get_current_git_branch()
  " http://stackoverflow.com/questions/2863756/is-there-a-single-git-command-to-get-the-current-tag-branch-and-commit
  return s:sub(system('git describe --contains --all HEAD 2> /dev/null'),'\n$','')
endfunction

function! s:make_file_name()
  let base_path = '~/vim-sessions'
  if exists("g:BranchSession_base_path")
    let base_path = s:sub(g:BranchSession_session_base_path,'\/+$','')
  endif
  return base_path . '/' . g:BranchSession_prefix . '__' . g:BranchSession_branch . '.vim'
endfunction

function! s:setup_autosave()
  augroup BranchSessionAutosave
    au!
    au VimLeave * call SaveBranchSession()
  augroup end
endfunction

function! LoadBranchSession(prefix) abort
  " find out current git branch
  let branch = s:get_current_git_branch()
  if empty(branch)
    throw 'Git branch is empty - are you in a git repo?'
    return 0
  endif

  let g:BranchSession_branch = branch
  let g:BranchSession_prefix = a:prefix
  let file_name = s:make_file_name()
  let glob_name = glob(file_name)

  call s:setup_autosave()
  if filereadable(glob_name)
    exe 'source ' . glob_name
  else
    throw 'No existing file found with name ' . file_name . '. A file will be created when you save current branch session or exit.' 
    return 0
  endif
endfunction

function! SaveBranchSession() abort
  if exists("g:BranchSession_branch") && exists("g:BranchSession_prefix")
    exe 'mks! ' . s:make_file_name()
  endif
endfunction
