dist="./modules"

# build
(cd output; grunt build)

# copy
mkdir -p $dist

# copy the output module
rsync -av output/dist/* $dist/output/

# copy legacy modules
rsync -av assets welcome intro switcher $dist/