# SHOUT.sh
# From an original implementation by  @jthistle on github
#
# Alternative iplementation as amended in:
# https://twitter.com/saruspete/status/1149281131612770304
# and related thread.
#
# Note the cute hack to chain shell functions:
#
# eval "$(echo " foo_orig()";
# declare -f foo | tail -n +2)"
# foo() {
#       # do some new stuff ...
#       # run original function
#       foo_orig
# }
#
# Using it makes me feel somewhat unclean, though.
#
if [[ x$ALF_CMNFH == x ]]; then
  # check pre-existing handler
  if [[ x$(typeset -f command_not_found_handle ) != x ]]; then
    eval "$(echo " command_not_found_handle_orig()";
                declare -f command_not_found_handle | tail -n +2)"
  fi
fi

function command_not_found_handle {
  # -u makes upppercase
  typeset -u allcaps="$1"
  # -i is integer
  typeset -i ret=127
  if [[ "$1" == "$allcaps" ]]; then
    #-l makes lowercase
    typeset -l cmd="$1";
    shift
    sudo "$cmd" "$@"
    ret=$?
  else
    if [[ x$(typeset -f command_not_found_handle_orig) != x ]]; then
      command_not_found_handle_orig "$@"
    else
      echo "$1: command not found" 1>&2
    fi
  fi
  return $ret
}
# avoid loops
export ALF_CMNFH=1
# Useful shortcut maps  ^V to  up-arrow^A<esc>u^E, ie recall last command go to BOL, upcase first word.
# better than the alias S=sudo !!, as it allows you to back off before hitting CR.
bind '"\C-v": "\e[A\C-a\eu\C-e"'
# For Emacs:
# Local Variables:
# mode: shell-script
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# SHOUT.sh ends
