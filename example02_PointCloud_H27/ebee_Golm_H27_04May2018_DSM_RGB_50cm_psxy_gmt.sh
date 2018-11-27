#!/bin/bash
gmt gmtset MAP_FRAME_PEN    2
gmt gmtset MAP_FRAME_WIDTH    0.1
gmt gmtset MAP_FRAME_TYPE     plain
gmt gmtset FONT_TITLE    Helvetica-Bold
gmt gmtset FONT_LABEL    Helvetica-Bold 14p
gmt gmtset PS_PAGE_ORIENTATION    landscape
gmt gmtset PS_MEDIA    A4
gmt gmtset FORMAT_GEO_MAP    D
gmt gmtset MAP_DEGREE_SYMBOL degree
gmt gmtset PROJ_LENGTH_UNIT cm

#create links
if [ ! -e Golm_H27_29_soda_04May2018_UTM33N_WGS84_50cm_gc_XYZcRGB.csv ]
then
    ln -s ../Golm_H27_29_soda_04May2018_UTM33N_WGS84_50cm_gc_XYZcRGB.csv Golm_H27_29_soda_04May2018_UTM33N_WGS84_50cm_gc_XYZcRGB.csv
fi

FN1=ebee_Golm_H27_04May2018_50cm_psxyz_elevation
DEM_CPT=dem2_color.cpt
gmt makecpt -D -T65/85/1 -Cplasma >$DEM_CPT
TITLE='Haus 27 and 29 - Elevation'
gmt select -i0:2,2 Golm_H27_29_soda_04May2018_UTM33N_WGS84_50cm_gc_XYZcRGB.csv | gmt plot3d -p165/40 -Sc0.02 -C$DEM_CPT -JX8 -JZ3 -R362150/362400/5808400/5808600/65/85 -Xc -Yc -png $FN1

FN2=ebee_Golm_H27_04May2018_50cm_psxyz_class.ps
CLASS_CPT=cl_color.cpt
gmt makecpt -N -T0/8/1 -Ccategorical >$CLASS_CPT
TITLE='Haus 27 and 29 - Classified PC'
gmt plot3d -p165/40 -Sc0.04 -a3 -C$CLASS_CPT Golm_H27_29_soda_04May2018_UTM33N_WGS84_50cm_gc_XYZcRGB.csv -JX8 -JZ3 -R362150/362400/5808400/5808600/65/85 -Xc -Yc -png $FN2

FN3=ebee_Golm_H27_04May2018_50cm_psxyz_RGB
TITLE='Haus 27 and 29 - RGB'
gmt select -i0:2,4:6 Golm_H27_29_soda_04May2018_UTM33N_WGS84_50cm_gc_XYZcRGB.csv | gmt plot3d -p165/40 -Sc0.04 -Cred -JX8 -JZ3 -R362150/362400/5808400/5808600/65/85 -Xc -Yc -png $FN3
