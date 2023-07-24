PATH="$HOME/.local/bin:$PATH"

if test -n "$BASH"; then
  SOURCE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
elif test -n "$ZSH_NAME"; then
  SOURCE="$( dirname -- "$( readlink -f -- "$0"; )"; )"
else
  echo 'Error : Unable to detect shell. Only bash and zsh are supported'
  return 1
fi

PROJECT_ROOT="$SOURCE"
export PROJECT_ROOT

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

export MAMBA_ROOT_PREFIX="$SOURCE/.micromamba"
export MAMBA_EXE="$MAMBA_ROOT_PREFIX/micromamba"

ENV_FILE_PATH="$PROJECT_ROOT/environment.yml"

# Read project name from environment file.
PROJECT_NAME="$( grep '^name:' $ENV_FILE_PATH | sed 's/^name: //' )"

if [ -z "$PROJECT_NAME" ]; then
   echo 'Error : Unable to detect project name. Please check the environment file.'
   return 1
fi

if ! [ -f $MAMBA_ROOT_PREFIX/micromamba ]; then
   mkdir -p $MAMBA_ROOT_PREFIX/etc/profile.d

   echo 'Downloading Micromamba ...'
   cd $MAMBA_ROOT_PREFIX

   if [ $OS = "darwin" ]; then
      if [ "$(uname -m)" = "x86_64" ]; then
         curl -Ls https://micro.mamba.pm/api/micromamba/osx-64/1.0.0 | tar -xvj --strip-components=1 -C . bin/micromamba
      else
         curl -Ls https://micro.mamba.pm/api/micromamba/osx-arm64/1.0.0 | tar -xvj --strip-components=1 -C . bin/micromamba
      fi
   elif [ $OS = "linux" ]; then
      if [ "$(uname -m)" = "x86_64" ]; then
         curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/1.0.0 | tar -xvj --strip-components=1 -C . bin/micromamba
      else
         echo 'Error : Unsupported system'
         return 1
      fi
   else
      echo 'Error : Unsupported system'
      return 1
   fi
   cd -

   eval "$(.micromamba/micromamba shell hook --shell=posix)"
   printf '%s\n' "$(.micromamba/micromamba shell hook --shell=posix)" > $MAMBA_ROOT_PREFIX/etc/profile.d/micromamba.sh

   touch $MAMBA_ROOT_PREFIX/.env.$PROJECT_NAME
fi

if command -v micromamba &> /dev/null; then
   #init micromamba environment.
   micromamba create -y --file $ENV_FILE_PATH
   micromamba activate $PROJECT_NAME
else
   echo 'Error : micromamba not installed properly'
   return 1
fi

return 0
