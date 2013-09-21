dist="./modules"

# build
(cd output; grunt build)

# copy
mkdir -p $dist
rsync -av output/dist/* $dist/output/
rsync -av assets welcome intro switcher $dist/