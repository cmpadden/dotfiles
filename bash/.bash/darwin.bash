#!/usr/bin/env bash

! [[ "$OSTYPE" =~ "darwin"* ]] && return

# filter `.DS_Store` from bash completion
export FIGNORE=$FIGNORE:.DS_Store

export PATH="/opt/homebrew/bin:$PATH"

if [ ! -x "$(command -v brew)" ]; then
    warn 'Homebrew is not installed (see https://brew.sh/)'
fi

BREW_PREFIX="$(brew --prefix)"

# gcloud bash completion
if [[ -d "$BREW_PREFIX/Caskroom/google-cloud-sdk" ]]; then
    # shellcheck source=/dev/null
    source "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
    # shellcheck source=/dev/null
    source "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
fi

# OSX 10.15 SILENCE BASH DEPRECATION MESSAGE
export BASH_SILENCE_DEPRECATION_WARNING=1

# Node.js via `nvm`

if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    # shellcheck source=/dev/null
    source "/opt/homebrew/opt/nvm/nvm.sh"
fi

if [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
    # shellcheck source=/dev/null
    source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# if [ ! -L "/Library/Java/JavaVirtualMachines/openjdk.jdk" ]; then
#     echo "The /Library/Java/JavaVirtualMachines/openjdk.jdk file is missing"
#     echo "See \`brew info openjdk\` for more information"
# fi

# if [ -f /usr/libexec/java_home ]; then
#   JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
#   export JAVA_HOME
# fi

# if [ -d /usr/lib/jvm/java-16-openjdk ]; then
#     export JAVA_HOME=/usr/lib/jvm/java-16-openjdk
# fi

# if [ -d /usr/lib/jvm/java-15-openjdk ]; then
#     export JAVA_HOME=/usr/lib/jvm/java-15-openjdk
# fi

# if [ -d /usr/lib/jvm/java-8-openjdk ]; then
#     export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/jre
# fi
