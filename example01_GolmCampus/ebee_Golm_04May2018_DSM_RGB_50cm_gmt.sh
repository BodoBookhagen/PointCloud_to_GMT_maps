#!/bin/bash
gmt gmtset MAP_FRAME_PEN    2
gmt gmtset MAP_FRAME_WIDTH    0.1
gmt gmtset MAP_FRAME_TYPE     plain
gmt gmtset FONT_TITLE    Helvetica-Bold
gmt gmtset FONT_LABEL    Helvetica-Bold 14p
gmt gmtset PS_PAGE_ORIENTATION    portrait
gmt gmtset PS_MEDIA    A4
gmt gmtset FORMAT_GEO_MAP    D
gmt gmtset MAP_DEGREE_SYMBOL degree
gmt gmtset PROJ_LENGTH_UNIT cm

#create links
if [ ! -e sodaall_orthoRGB_5cm.tif ]
then
    ln -s ../sodaall_orthoRGB_5cm.tif sodaall_orthoRGB_5cm.tif
fi

if [ ! -e sodaall_1stproc_densecloud_wgs84_UTM33N_50cm_DSM.tif ]
then
    ln -s ../sodaall_1stproc_densecloud_wgs84_UTM33N_50cm_DSM.tif sodaall_1stproc_densecloud_wgs84_UTM33N_50cm_DSM.tif
fi

#50cm:
#First, warp RGB file to align with integer UTM coordinates (-tap option)
if [ ! -e sodaall_orthoRGB_50cm.tif ]
then
    echo "warping sodaall_orthoRGB_50cm.tif"
    gdalwarp -multi -tap -tr 0.5 0.5 -r bilinear ./sodaall_orthoRGB_5cm.tif ./sodaall_orthoRGB_50cm.tif -s_srs epsg:32633 -t_srs epsg:32633 -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
fi


#Extract individual bans and convert to NetCDF (sometimes its better to use gmt grdconvert because you can give NaN value)
if [ ! -e ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_red.nc ]
then
    echo "convert to GMT NetCDF ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_red.nc"
    gdal_translate ./sodaall_orthoRGB_50cm.tif -b 1 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band1.tif -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
    gmt grdconvert ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band1.tif=gd/1/0/0 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_red.nc
    gdal_translate ./sodaall_orthoRGB_50cm.tif -b 2 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band2.tif -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
    gmt grdconvert ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band2.tif=gd/1/0/0 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_green.nc
    gdal_translate ./sodaall_orthoRGB_50cm.tif -b 3 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band3.tif -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
    gmt grdconvert ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band3.tif=gd/1/0/0 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_blue.nc
# Alternatively, you can use gdal_translate to generate BYTE nc files
#    gdal_translate -ot Byte -of NetCDF ./sodaall_orthoRGB_50cm.tif -b 1 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_red.nc -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
#    gdal_translate -ot Byte -of NetCDF ./sodaall_orthoRGB_50cm.tif -b 2 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_green.nc -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
#    gdal_translate -ot Byte -of NetCDF ./sodaall_orthoRGB_50cm.tif -b 3 ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_blue.nc -co COMPRESS=DEFLATE -co ZLEVEL=7 -co PREDICTOR=2
fi

#remove tif files of individual files
if [ -e ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band1.tif ]
then
    rm -fr ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band1.tif ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band2.tif ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_band3.tif
fi

#rm sodaall_1stproc_densecloud_wgs84_UTM33N_50cm_DSM.nc sodaall_1stproc_densecloud_wgs84_UTM33N_50cm_DSM_HS.nc
DEM_GRD=sodaall_1stproc_densecloud_wgs84_UTM33N_50cm_DSM.nc
if [ ! -e $DEM_GRD ]
then
    echo "convert $DEM_GRD"
    gmt grdconvert ${DEM_GRD::-3}.tif=gd/1/0/-9999 -G$DEM_GRD
fi

#clip DEM to orthophoto:
if [ ! -e ${DEM_GRD::-3}_aligned.nc ]
then
    echo "convert ${DEM_GRD::-3}_aligned.nc"
    gmt grdsample $DEM_GRD -Rebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_blue.nc -nb -G${DEM_GRD::-3}_aligned.nc
fi

DEM_GRD=${DEM_GRD::-3}_aligned.nc
DEM_GRD_HS=${DEM_GRD::-3}_HS.nc
if [ ! -e $DEM_GRD_HS ]
then
    echo "generate hillshade $DEM_GRD_HS"
    gmt grdgradient $DEM_GRD -A315/45 -Nt0.6 -G$DEM_GRD_HS
fi

POSTSCRIPT1=ebee_Golm_04May2018_DSM_50cm.ps
DEM_CPT=dem2_color.cpt
gmt makecpt -N -T65/110/2 -Cdem2 >$DEM_CPT
gmt grdimage $DEM_GRD -I$DEM_GRD_HS -Jx1:12500 -C$DEM_CPT -R$DEM_GRD -Q -B+t"eBee May-04-2018 DSM: 50cm" -Xc -Yc -E300 -K >$POSTSCRIPT1
gmt pscoast -R -Ju33N/1:12500 -N1 -K -O -Df -B0.5mSWne --FONT_ANNOT_PRIMARY=12p --FORMAT_GEO_MAP=ddd:mmF -K >> $POSTSCRIPT1
gmt psbasemap -R -J -O -K --FONT_ANNOT_PRIMARY=10p -LjLB+c52:53N+f+w0.4k+l1:12,500+u+o0.5c --FONT_LABEL=10p >> $POSTSCRIPT1
gmt psscale -R -J -DjTRC+o2.5c/0.3c/+w6c/0.3c+h -C$DEM_CPT -I -F+gwhite+r1p+pthin,black -Bx15 -By+lMeter --FONT=12p --FONT_ANNOT_PRIMARY=12p --MAP_FRAME_PEN=1 --MAP_FRAME_WIDTH=0.1 -O -K >> $POSTSCRIPT1
#creating map insert
RANGE=10/14/50/54
PROJECTION=M2
gmt psbasemap -Bpx1d -Bpy1d -Ju33N/1:800000 -R$RANGE -P -K -V -X5c -Y25c >> $POSTSCRIPT1
gmt pscoast -J -R -Df -A10 -EDE -I1 -P -K -O -V >> $POSTSCRIPT1
#adding red star at Golm:
echo "12.97 52.41" >Golm_location.txt
gmt psxy -R -J -Sa5c -Gred -O -K -V -P Golm_location.txt >> $POSTSCRIPT1
convert -quality 100 -density 300 $POSTSCRIPT1 ${POSTSCRIPT1::-3}.png

POSTSCRIPT2=ebee_Golm_04May2018_RGB_50cm.ps
gmt grdimage ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_red.nc ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_green.nc ebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_blue.nc -I$DEM_GRD_HS -Jx1:10000 -R$DEM_GRD -Q -B+t"Campus Golm: eBee May-04-2018, RGB 50cm" -Xc -Yc -E300 -K >$POSTSCRIPT2
gmt pscoast -R -Ju33N/1:10000 -N1 -K -O -Df -B0.5mSWne --FONT_ANNOT_PRIMARY=12p --FORMAT_GEO_MAP=ddd:mmF>> $POSTSCRIPT2
gmt psbasemap -R -J -O -K --FONT_ANNOT_PRIMARY=10p -LjLB+c52:53N+f+w0.4k+l1:10,000+u+o0.5c --FONT_LABEL=10p >> $POSTSCRIPT2
convert -quality 100 -density 300 $POSTSCRIPT2 ${POSTSCRIPT2::-3}.png

POSTSCRIPT3=ebee_Golm_04May2018_DSM_50cm_grdview_image.ps
DEM_CPT=dem2_color.cpt
gmt makecpt -N -T65/110/2 -Cdem2 >$DEM_CPT
gmt grdview -p170/30 $DEM_GRD -Jx1:4000 -JZ3c -I$DEM_GRD_HS -G$DEM_GRD -C$DEM_CPT -R361800/362600/5808200/5809000/65/110 -Qi  -Xc -Yc >$POSTSCRIPT3
convert -quality 100 -density 300 $POSTSCRIPT3 ${POSTSCRIPT3::-3}.png

POSTSCRIPT4=ebee_Golm_04May2018_DSM_50cm_grdview_surface.ps
DEM_CPT=dem2_color.cpt
gmt makecpt -N -T65/110/2 -Cdem2 >$DEM_CPT
gmt grdview -p170/30 $DEM_GRD -Jx1:4000 -JZ3c -I$DEM_GRD_HS -G$DEM_GRD -C$DEM_CPT -R361800/362600/5808200/5809000/65/110 -Qs  -Xc -Yc >$POSTSCRIPT4
convert -quality 100 -density 300 $POSTSCRIPT4 ${POSTSCRIPT4::-3}.png

#draping of RGB doesn't work yet - color scale is not properly recognized.
# POSTSCRIPT5=ebee_Golm_04May2018_DSM_50cm_grdview_RGB.ps
# gmt grdview -p170/30 $DEM_GRD -Jx1:4000 -JZ3c -I$DEM_GRD_HS \
# -Gebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_blue.nc -Gebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_green.nc -Gebee_Golm_Color_04May2018_agisoft_orthophoto_50cm_red.nc \
# -R361800/362600/5808200/5809000/50/100 -Qi  -Xc -Yc >$POSTSCRIPT5
# convert -quality 100 -density 300 $POSTSCRIPT5 ${POSTSCRIPT5::-3}.png

