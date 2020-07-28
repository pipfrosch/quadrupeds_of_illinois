#!/bin/bash

function getfonts {
  GITDIR="$1"
  EPUBDIR="$2"
  pushd ${GITDIR}
  if [ ! -f fonts.sha256.txt ]; then
    echo "No fonts checksum"
    exit 1
  fi
  cat fonts.sha256.txt |cut -d' ' -f3 |while read fontfile; do
    if [ ! -f ${fontfile} ]; then
      curl -O https://misc.pipfrosch.com/ePubFonts/${fontfile}
    fi
  done
  popd
  pushd ${EPUBDIR}
  if [ ! -f fonts.sha256.txt ]; then
    echo "No fonts checksum"
    exit 1
  fi
  cat fonts.sha256.txt |cut -d' ' -f3 |while read fontfile; do
    cp -p ${GITDIR}/${fontfile} .
  done
  sha256sum -c fonts.sha256.txt
  if [ $? -ne 0 ]; then
    echo "Font checksum problem"
    exit 1;
  fi
  rm -f fonts.sha256.txt .gitignore
  popd
}

CWD=`pwd`

TMP=`mktemp -d /tmp/QUADILL.XXXXXXXX`

pushd ${TMP}

git clone https://github.com/pipfrosch/quadrupeds_of_illinois.git

cd quadrupeds_of_illinois
# switch to branch goes here

getfonts ${CWD}/TheArticle/EPUB/fonts ${TMP}/quadrupeds_of_illinois/TheArticle/EPUB/fonts

cd TheArticle/EPUB

python3 ../../tools/updateTimestamp.py content.opf
cd ../..

# generate atom file goes here
pushd ${CWD}/opds
cat epub.json |sed -e s?"\.atom"?"-noitalics.atom"?g \
              |sed -e s?"\.kepub.epub"?"-noitalics.kepub.epub"?g \
              > epub-noitalics.json
popd

python3 tools/generateOPDS.py TheArticle/EPUB/content.opf ${CWD}/opds/epub.json
python3 tools/generateOPDS.py TheArticle/EPUB/content.opf ${CWD}/opds/epub-noitalics.json

cat opds/Quadrupeds-Illinois.atom > ${CWD}/opds/Quadrupeds-Illinois.atom
cat opds/Quadrupeds-Illinois-noitalics.atom > ${CWD}/opds/Quadrupeds-Illinois-noitalics.atom

rm -f ${CWD}/opds/epub-noitalics.json

cd TheArticle

echo -n application/epub+zip >mimetype

zip -r -X Book.zip mimetype META-INF EPUB
mv Book.zip Quadrupeds-Illinois.kepub.epub

#dyslexia friendly version
cat EPUB/css/noitalics.css >> EPUB/css/a11y.css
zip -r -X Book.zip mimetype META-INF EPUB
mv Book.zip Quadrupeds-Illinois-noitalics.kepub.epub

sh ../tools/epubcheck.sh Quadrupeds-Illinois.kepub.epub

if hash ace 2>/dev/null; then
  if [ ! -f ${CWD}/AceReport/noace.tmp ]; then
    ace -f -s -o AceReport Quadrupeds-Illinois.kepub.epub
    rm -rf ${CWD}/AceReport/data
    [ ! -d ${CWD}/AceReport ] && mkdir ${CWD}/AceReport
    mv AceReport/data ${CWD}/AceReport/
    mv AceReport/report.html ${CWD}/AceReport/
    mv AceReport/report.json ${CWD}/AceReport/
    echo "Accessibility report written to AceReport directory"
    echo `pwd`
  fi
fi

mv Quadrupeds-Illinois.kepub.epub ${CWD}/
mv Quadrupeds-Illinois-noitalics.kepub.epub ${CWD}/

popd

if hash ace 2>/dev/null; then
  if [ -f AceReport/.gitignore ]; then
    if [ ! -f AceReport/noace.tmp ]; then
      git commit -m "update AceReport" AceReport/report.*
    fi
  fi
fi

rm -rf ${TMP}

exit 0

