if [[ "" == "$1" ]] ; then
   echo "Give your secret key base as a parameter to this script"
   exit 1
fi

MIX_ENV=prod PORT=4000 SECRET_KEY_BASE=$1 elixir --detached -S mix phx.server
