#!/bin/bash
#----------------
#Lee información de archivos PDF, EPUB, ZIP y RAR e imprime una en formato compatible con tellico.
#necesita:
#	EPUB: unzip, imagemagick(puede funcionar sin esto);
#	PDF: pdfinfo;
#	ZIP: zip;
#	RAR: rar.
#----------------
# PREAMBLE="<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE tellico PUBLIC '-//Robby Stephenson/DTD Tellico V11.0//EN' 'http://periapsis.org/tellico/dtd/v11/tellico.dtd'><tellico xmlns=\"http://periapsis.org/tellico/\" syntaxVersion=\"11\">"
# echo $PREAMBLE
# echo "<entry id=\"0\">"
# echo "<url>file://"$1"</url>"
TARGETFILE="*.opf"
declare -u FILEEXT
FILEEXT="${1##*.}"
# declare -u FILEEXT
# FILEEXT=$FILEEXT
# EPUBFILE="$(echo "$1"|sed 's/%20/ /g'|sed 's|file:\/\/||')"
# EPUBFILE="$(echo -e $(echo "$1"|sed -e 's/%/\\x/g' -e 's|file:\/\/||'))"
#forma más sencilla de cambiar el uri a un path normal. Todavía uso sed para el file://, pero es uno solo y un solo echo.
EPUBFILE="$(echo -e "${1//%/\\x}"|sed 's|file:\/\/||')"
if [ $FILEEXT = "PDF" ]
  then
  TEXT="$(pdfinfo $EPUBFILE)"
fi
# echo "$TEXT"
# echo '<?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE tellico PUBLIC "-//Robby Stephenson/DTD Tellico V11.0//EN' 'http://periapsis.org/tellico/dtd/v11/tellico.dtd">
# <tellico xmlns="http://periapsis.org/tellico/" syntaxVersion="11">
#  <collection title="Mis archivos" type="12">
#   <fields>
#    <field title="Nombre" flags="0" category="General" format="2" description="Título" type="1" name="title">
#     <prop name="template">%{URL}</prop>
#    </field>
#    <field title="URL" flags="0" category="Archivo" format="4" type="7" name="url"/>
#    <field title="Autor" flags="7" category="General" format="2" type="1" name="autor">
#     <prop name="bibtex">author</prop>
#    </field>
#    <field title="Descripción" flags="6" category="General" format="4" type="1" name="description"/>
#    <field title="Género" flags="7" category="General" format="4" description="Género (separar con ;)" type="1" name="género"/>
#    <field title="Volumen" flags="6" category="General" format="4" type="6" name="volume"/>
#    <field title="Tamaño" flags="0" category="Archivo" format="4" type="1" name="size"/>
#    <field title="Carpeta" flags="4" category="Archivo" format="4" type="7" name="folder">
#     <prop name="default">file:///home/vlad/Descargas/books/</prop>
#     <prop name="template">%{URL}</prop>
#    </field>
#    <field title="Tipo MIME" flags="6" category="Archivo" format="4" type="1" name="mimetype"/>
#    <field title="Tipo de entrada" flags="2" category="General" format="4" description="Tipo de entrada (libro, archivador, etc.)" type="3" allowed="Archivo de Libro Individual;Archivador de Libros" name="tipo-de-entrada"/>
#    <field title="Creado" flags="0" category="General" format="4" type="1" name="created"/>
#    <field title="Modificado" flags="0" category="General" format="4" type="1" name="modified"/>
#    <field title="Metainformación" flags="1" category="Metainformación" format="4" type="8" name="metainfo">
#     <prop name="column1">Propiedad</prop>
#     <prop name="column2">Valor</prop>
#     <prop name="columns">2</prop>
#    </field>
#    <field title="Icono" flags="0" category="Icono" format="4" type="10" name="icon"/>
#    <field title="Notas" flags="0" category="Notas" format="4" type="2" name="notas"/>
#   </fields>'
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tellico PUBLIC "-//Robby Stephenson/DTD Tellico V9.0//EN" "http://periapsis.org/tellico/dtd/v9/tellico.dtd">
<tellico syntaxVersion="9" xmlns="http://periapsis.org/tellico/">
 <collection title="Mis archivos" type="12">
  <fields>
   <field title="Nombre" flags="0" category="General" format="2" description="Título" type="1" name="title"/>
   <field title="URL" flags="0" category="Archivo" format="4" type="7" name="url"/>
   <field title="Directorio" flags="0" category="Archivo" format="4" type="7" name="carpe"/>
   <field title="Autor" flags="7" category="General" format="2" type="1" name="autor"/>
   <field title="Descripción" flags="6" category="General" format="4" type="1" name="description"/>
   <field title="Género" flags="7" category="General" format="4" description="Género (separar con ;)" type="1" name="género"/>
   <field title="Creado" flags="0" category="General" format="4" type="1" name="created"/>
   <field title="Icono" flags="0" category="Icono" format="4" type="10" name="icon"/>
   <field title="Notas" flags="0" category="Notas" format="4" type="2" name="notas"/>
  </fields>'
echo "<entry id=\"0\">"
# echo "<entry>"
#-----------Leo el titulo
TAG="title"
TELLTAG="title"
if [ $FILEEXT = "EPUB" ]
  then
  TITLE="$(unzip -c "$EPUBFILE" $TARGETFILE|sed -n '/dc:'$TAG'>/,/\dc:'$TAG'>/p'| sed -n 's/dc:'$TAG'[^>]*/'$TELLTAG'/pg')"
elif [ $FILEEXT = "PDF" ]
  then
  TITLE="<"$TELLTAG">"$(echo "$TEXT"|grep  "Title:"|sed "s/Title:[ ]*//")"</"$TELLTAG">"
fi
echo $TITLE
#-----------Leo la URL
echo "<url>"$1"</url>"
# # echo " "
#-----------Leo el genero
TAG="subject"
TELLTAG="género"
if [ $FILEEXT = "EPUB" ]
  then
  SUBJECT="$(unzip -c "$EPUBFILE" $TARGETFILE|sed -n '/dc:'$TAG'>/,/\dc:'$TAG'>/p'| sed -n 's/dc:'$TAG'[^>]*/'$TELLTAG'/pg')"
elif [ $FILEEXT = "PDF" ]
  then
  SUBJECT="<"$TELLTAG">"$(echo "$TEXT"|grep  "Subject:"|sed "s/Subject:[ ]*//")"</"$TELLTAG">"
fi
echo $SUBJECT
# # echo " "
#-----------Leo el autor
TAG="creator"
TELLTAG="autor"
if [ $FILEEXT = "EPUB" ]
  then
  AUTOR="$(unzip -c "$EPUBFILE" $TARGETFILE|sed -n '/dc:'$TAG'>/,/\dc:'$TAG'>/p'| sed -n 's/dc:'$TAG'[^>]*/'$TELLTAG'/pg')"
elif [ $FILEEXT = "PDF" ]
  then
  AUTOR="<"$TELLTAG">"$(echo "$TEXT"|grep  "Author:"|sed "s/Author:[ ]*//")"</"$TELLTAG">"
fi
echo $AUTOR
# echo " "
#-----------Leo una descripcion en los EPUB
TAG="description"
TELLTAG="notas"
if [ $FILEEXT = "EPUB" ]
  then
  NOTAS="$(unzip -c "$EPUBFILE" $TARGETFILE|sed -n '/dc:'$TAG'>/,/\dc:'$TAG'>/p'| sed -n 's/dc:'$TAG'[^>]*/'$TELLTAG'/pg')"
 elif [ $FILEEXT = "PDF" ]
   then
#   NOTAS="<"$TELLTAG">"$(echo "$TEXT"|grep  "Title:"|sed "s/Title:[ ]*//")"</"$TELLTAG">"
   NOTAS=""
fi
echo $NOTAS
# # echo " "
#-----------Leo la fecha de en que fue hecho el documento. No deberia ser la de creacion del archivo, pero para muchos PDF lo es.
TAG="date"
TELLTAG="created"
if [ $FILEEXT = "EPUB" ]
  then
  DATE="$(unzip -c "$EPUBFILE" $TARGETFILE|sed -n '/dc:'$TAG'>/,/\dc:'$TAG'>/p'| sed -n 's/dc:'$TAG'[^>]*/'$TELLTAG'/pg')"
elif [ $FILEEXT = "PDF" ]
  then
  DATE="<"$TELLTAG">"$(echo "$TEXT"|grep  "CreationDate:"|sed "s/CreationDate:[ ]*//")"</"$TELLTAG">"
fi
echo $DATE
#-----------Busco el icono de los EPUB
if [ $FILEEXT = "EPUB" ]
  then
  ICOFILE=$(mktemp)
  unzip -qq -p "$EPUBFILE" cover.* -x cover.html > $ICOFILE
  ICOSIZE=$(stat -c%s $ICOFILE)
  if [ $ICOSIZE -gt 1024 ]
    then
#     FACTOR=$(expr 10 / $ICOSIZE * 100)
#     echo $FACTOR> /home/vlad/mis_programas/tellico_up/salida
    convert $ICOFILE -resize 50 $ICOFILE
  fi
  if [ $ICOSIZE -eq 0 ]
    then
    rm $ICOFILE
  else
    echo "<icon>"$ICOFILE"</icon>"
  fi
fi
#-----------LEo contenido de zip y rar
# if [ $FILEEXT = "EPUB" ]
case $FILEEXT in
  "ZIP")
      echo "<notas>"
      zip -sf "$EPUBFILE"|sed "s/$/\&lt;br\/>/"
      echo "</notas>"
      ;;
  "RAR")
      echo "<notas>"
      echo "Archive contains:&lt;br/>"
      rar l "$EPUBFILE" |sed -n "/------/,/------/p"|sed "s/$/\&lt;br\/>/"
      echo "</notas>"
      ;;
esac
#-----------Pongo la carpeta absoluta (machine dependent)
echo "<carpe>"$(dirname "$1")"</carpe>"
#-----------Cierro
echo "</entry>"
echo "<images/></collection></tellico>"
# echo $FILEEXT $EPUBFILE $AUTOR>> /home/vlad/mis_programas/tellico_up/salida
# if [ "${FILEEXT^^}" = "EPUB" ];
#   then
#   echo "o"
# fi