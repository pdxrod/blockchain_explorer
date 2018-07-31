if [[ ! -f assets/node_modules/brunch/bin/brunch ]] ; then
	echo "You need to get brunch"
	exit 1
fi

rm priv/static/js/*
cd assets
./node_modules/brunch/bin/brunch build
cd ..

