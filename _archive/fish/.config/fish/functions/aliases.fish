###############################################################################
#                                   Docker                                    #
###############################################################################

function drmf
  command docker rmi -f (docker images -q)
end

function drmp
  command docker kill (docker ps -q)
end

###############################################################################
#                                   Python                                    #
###############################################################################

function ipy
  command python -m IPython --matplotlib
end

function mkpyenv
  command echo "layout python-venv python3" > .envrc && direnv allow
end

###############################################################################
#                                Google Cloud                                 #
###############################################################################

function gproject
  command gcloud info --format='value(config.project)'
end

function gssh
  command gcloud beta compute ssh --zone "us-east4-a" $argv -- -p 8800
end

function gscp
  command gcloud beta compute scp --port 8800 --zone "us-east4-a" $argv
end

################################################################################
##                            Built-in Alternatives                            #
################################################################################

function vim
  if hash nvim 2>/dev/null
    command nvim $argv
  else
    command vim $argv
  end
end

function ls
  if hash exa 2>/dev/null
    command exa \
      -l \
      --classify \
      --group \
      --time-style long-iso \
      --group-directories-first \
      $argv
  else
    command ls $argv
  end
end

function cat
  if hash bat 2>/dev/null
    command bat \
      --theme=ansi-dark \
      --style header,grid \
      --pager=never \
      --wrap=never \
      $argv
  else
    command cat $argv
  end
end

function grep
  if hash ag 2>/dev/null
    command ag --hidden --ignore .git $argv
  else
    command grep $argv
  end
end

###############################################################################
#                                    Misc.                                    #
###############################################################################

function cheat
  if count $argv > 1
    command curl cheat.sh/$argv[1]
  else
    echo "Argument must be provided..."
  end
end

# ssh to a remote host running `tmux`
function ssht
  command ssh -t $argv "command -v tmux && tmux -u new-session -A -s default"
end
