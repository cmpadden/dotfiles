function fish_prompt --description 'Informative prompt'
    #Save the return status of the previous command
    set -l last_pipestatus $pipestatus

    switch "$USER"

        case root toor
            printf '%s@%s %s%s%s# ' \
                $USER \
                (prompt_hostname) \
                (set -q fish_color_cwd_root and set_color $fish_color_cwd_root or set_color $fish_color_cwd) \
                (prompt_pwd) \
                (set_color normal)

        case '*'
            set -l pipestatus_string (
                __fish_print_pipestatus " [" "] " "|"  \
                (set_color $fish_color_status)  \
                $last_pipestatus)

            # direnv python prompt
            # https://github.com/direnv/direnv/wiki/Python
            if test -n "$VIRTUAL_ENV" -a -n "$DIRENV_DIR"
                set venv (printf '%s ' (basename $VIRTUAL_ENV))
            end

            printf '%s%s%s%s%s%s \f\r> ' \
                (printf '%s ' (string trim (fish_git_prompt))) \
                $venv \
                (set_color $fish_color_cwd) \
                $PWD \
                $pipestatus_string \
                (set_color normal)
    end
end

function fish_default_mode_prompt --description "Overridden default mode for the prompt"
    if test "$fish_key_bindings" = fish_vi_key_bindings
        or test "$fish_key_bindings" = fish_hybrid_key_bindings
        switch $fish_bind_mode
            case default
                set_color green
                echo '[N]'
            case insert
                set_color green
                echo '[I]'
            case replace_one
                set_color green
                echo '[R]'
            case replace
                set_color cyan
                echo '[R]'
            case visual
                set_color magenta
                echo '[V]'
        end
        set_color normal
        echo -n ' '
    end
end
