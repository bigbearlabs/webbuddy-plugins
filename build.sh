dist="./dist"

# build
(cd output; grunt build)

# copy
mkdir -p $dist

# copy the output module
rsync -av --delete output/dist/* $dist/output/

# copy legacy modules
rsync -av --delete assets welcome intro switcher $dist/