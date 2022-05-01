# vim:ft=zsh ts=2 sw=2 sts=2
# Must use Powerline font, for \uE0A0 to render.

rc() {
  echo -n "%{$reset_color%}"
}

prompt_start() {
  echo -n "%{$fg_bold[default]%}%B┌$(rc)"
}

prompt_end() {
  echo -n "%{$fg_bold[default]%}\n└─੦ $(rc)"
}

username() {
   echo -n "%{$fg_bold[blue]%}%n$(rc)"
}

# current directory, two levels deep
directory() {
   echo "%{$fg_bold[cyan]%}@%2~$(rc)"
}

# current time with milliseconds
current_time() {
   echo "%*"
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi

  local PL_BRANCH_CHAR

  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=" on \uE0A0 "
  }

  local ref dirty mode repo_path

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      PL_BRANCH_CHAR=" %{$fg_bold[yellow]%}% on \uE0A0"
    else
      PL_BRANCH_CHAR=" %{$fg_bold[green]%}% on \uE0A0"
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info
 
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_git_user() {
  (( $+commands[git] )) || return
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != true ]]; then
    return
  fi

  local username
  local email

  username="$(git_current_user_name)"
  email="$(git_current_user_email)"

  if [[ -n $username ]]; then
    echo -n " %{$fg_bold[blue]%}% as ${username} "
  elif [[ -n $email ]]; then
    echo -n " %{$fg_bold[blue]%}% as ${email} "
  else
    echo -n " %{$fg_bold[yellow]%}% name or email not set for this repo "
  fi
} 

exists() {
  command -v $1 > /dev/null 2>&1
}

function prompt_node_version() {
  # Show NODE status only for JS/TS specific folders
 [[ -f package.json || -d node_modules || -n *.js(#qN^/) || *.ts(#qN^/) ]] || return

    local 'node_version'

    if exists fnm; then
      node_version=$(fnm current 2>/dev/null)
      [[ $node_version == "system" || $node_version == "node" ]] && return
    elif exists nvm; then
      node_version=$(nvm current 2>/dev/null)
      [[ $node_version == "system" || $node_version == "node" ]] && return
    elif exists nodenv; then
      node_version=$(nodenv version-name)
      [[ $node_version == "system" || $node_version == "node" ]] && return
    elif exists node; then
      node_version=$(node -v 2>/dev/null)
    else
      return
    fi

    echo -n "%{$fg_bold[green]%} ⬢ ${node_version} "
}

PROMPT='$(prompt_start)$(username)$(directory)$(prompt_git)$(prompt_git_user)$(prompt_end)'
RPROMPT='$(prompt_node_version)$(rc)'
