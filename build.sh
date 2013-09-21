(cd output; grunt build)

# copy to the WebBuddy project.
rsync -av output/dist/* ../WebBuddy/modules/output/