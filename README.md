# SHOUT.sh

## SYNOPSYS

converts ALL_CAPS commands to sudo all_caps

## USAGE

Source SHOUT.sh  (or stick it into your bashrc). Then when you type:

    $ YUM -y update
	
It will be converted to:

    $ sudo yum -y update

If you use this in your .bashrc you should probably reserve it for interactive shells, doing something along the lines of:

    if [[ x$PS1 != x ]]; then
	 . SHOUT.sh
    fi
 
## IMPLEMENTATION NOTES

  * The present implementation is full of bash-isms and will likely not run on any other shell.
  
  * The code runs instead of any not-found command invoked as an all caps verb. (So `/usr/bin/CAT` is not affected,  but `CAT` and `/USR/BIN/CAT` are.)

  * It runs as a `command_not_found_handle` by  pre-chaininig itself to any preexisting handle, which gets renamed to `command_not_found_handle_orig`. So things like automatic search of installable commands, which on Fedora is implementaed as a not-found handler (and which I find terminally irritating, but still) keep working. Also, in the rare case where an all-caps command actually exists, real commands will not be obscured.
  
  * OTOH, this cute prechaining trick may fail spectacularly and in unforeseen ways if other parts of your .bashrc & co. are also playing tricks with said handle. 
  
  * General *Caveat emptor* cautions apply.

## HISTORY

From an original implementation seen on twitter (and HN?): https://github.com/jthistle/SUDO.

Alas, the original implementation is not particularly fast:

    # Interesting, BUT...
    # SUDO - shout at bash to su commands
    # Distributed under GNU GPLv2, @jthistle on github
    
    shopt -s expand_aliases
    
    IFS_=${IFS}
    IFS=":" read -ra PATHS <<< "$PATH"
    
    # OUCH! ... this is bound to take forever.
    for i in "${PATHS[@]}"; do
    	for j in $( ls "$i" ); do
    		if [ ${j^^} != $j ] && [ $j != "sudo" ]; then
    			alias ${j^^}="sudo $j"
    		fi		
    	done
    done
    
    alias SUDO='sudo $(history -p !!)'
    
    IFS=${IFS_}
    
    # end SUDO

This prompted me to tweet along the lines of:

    # this might be an alternative
    
    function command_not_found_handle () {
        local allcaps=$(echo $1 | grep -E '^[A-Z0-9_-]+$')
        if [[ x$allcaps != x ]]; then
    	   local cmd=$(echo $1 | tr A-Z a-z)
    	   shift
    	   sudo $cmd "$@"
        else
    	   return 127
        fi
    }


Which provoked a fruitful tweet exchange (which I did not know was at all possible) viz. https://twitter.com/saruspete/status/1149281131612770304.

It's been sitting in my .bashrc for a few months, with no issues (but I do not use it heavily, see below).

I omitted the `alias SUDO='sudo $(history -p !!)'` thing, because:

  * I was not going to  test/investigate the ups and downs of interacting with history expansion, which I hate and mostly eschew;
  * I do SUDO su - a lot.


## LICENSE

GNU GENERAL PUBLIC LICENSE Version 2
