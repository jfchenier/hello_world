if test -n "$BASH"; then
  SOURCE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
elif test -n "$ZSH_NAME"; then
  SOURCE="$( dirname -- "$( readlink -f -- "$0"; )"; )"
else
  echo 'Error : Unable to detect shell. Only bash and zsh are supported'
  return 1
fi

PROJECT_NAME=$( basename $SOURCE )

export MAMBA_ROOT_PREFIX=$SOURCE/.micromamba
export MAMBA_EXE="$MAMBA_ROOT_PREFIX/micromamba"

eval "$($MAMBA_ROOT_PREFIX/micromamba shell hook --shell=posix)"

if command -v micromamba &> /dev/null; then
    micromamba activate $PROJECT_NAME
else
    echo 'Error : Unable to activate environment.'
    return 1
fi
