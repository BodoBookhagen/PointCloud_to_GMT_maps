# PointCloud_to_GMT_maps

This document-in-manual-style roughly outlines the steps necessary to take a point cloud, classify it, and display it as a map with GMT. Visualization with GMT includes 2.5D perspective views with points and meshes, but also 2D maps. Emphasis is put on open-source software (with the exception of LAStools that requires a license for full functionality). The following steps are described:

1. Preprocess and classify point-cloud data
    * including preprocessing of SfM pointclouds that are usually noisier than lidar pointclouds
2. Classifying a point cloud to generate Digital Surface Model (DSM) or Digital Terrain Model (DTM)
    * classification and DEM generation with [LAStools](https://rapidlasso.com/lastools/) and [pdal](https://pdal.io/)
3. Converting the LAZ files to properly organized shapefiles or GMT files 
    * attribute tables are converted
4. Generating map and perspective views from the gridded lidar data using GMT
5. Generating perspective views from point-cloud data

As an example dataset, we use a SfM point cloud of the University of Potsdam campus Golm collected on May-04-2018 with an [ebee Classic drone](https://www.sensefly.com/drone/ebee-mapping-drone/) using the [S.O.D.A.](https://www.sensefly.com/camera/sensefly-s-o-d-a/) camera. The Structure-from-Motion (SfM) processing was performed in [Agisoft Photoscan](http://www.agisoft.com/). Note: Agisoft will be renamed to Agisoft Metashape by the end of 2018. Flights and SfM processing was performed by Simon Riedl ([sriedl@uni-potsdam.de](sriedl@uni-potsdam.de)).
