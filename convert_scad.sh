tmpfile=$(mktemp /tmp/model.XXXXXX)
scadfile=$1
stlfile=$tmpfile.stl
glbfile=$tmpfile.glb
resultfile=$2

/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o $stlfile --export-format=binstl $scadfile 1>&2
/Volumes/Data/Applications/Blender.app/Contents/MacOS/Blender --background --python test.py -- $stlfile $glbfile 1>&2

cp $glbfile $resultfile

rm "$scadfile"
rm "$stlfile"
rm "$glbfile"
