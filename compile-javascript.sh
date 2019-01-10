if [[ ! -f assets/node_modules/brunch/bin/brunch ]] ; then
	echo "You need to get brunch - try 'cd assets && npm install'"
	exit 1
fi

if [[ ! -d priv/static ]] ; then
  mkdir -p priv/static
fi

if [[ -d priv/static/js ]] ; then
      rm priv/static/js/*
fi

cd assets
./node_modules/brunch/bin/brunch build
cd ..
