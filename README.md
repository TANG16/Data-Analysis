This repository contains code for reading in, parsing, cleaning, de-noising, analyzing, and plotting data from my nanomaterial-gas interaction experiments.  It contains the following files:

SCRIPTS
analysis_demo: a demo that shows the process of getting from a data file to plots

getLandCondBefore: a simple demo that shows how to get data out of heat pulses

PLOTTING FUNCTIONS
plotHeatPulseDataSets: plots heat pulse data sets, with a number of options

plotExposureResponses: plots exposure data sets

FUNCTIONS FOR MAKING BIG FILES EASIER TO DEAL WITH
breakupFile: breaks up a data file into multiple file, each with the same header data

keepEveryNthLine: keeps only every nth line of data from a data file

removeCols: removes columns from a data file

FUNCTIONS FOR GETTING DATA SETS
getHeatPulseDataSets: gets heat pulses from data points or data files

getExposureDataSets: gets data from each exposure in a set data points or a data file. 

getDataSets: gets many different kinds of data sets, including heat pulses and exposures, but right now doesn't work with plotting functions

FUNCTIONS FOR GETTING DATA POINTS
getDataPoints: get data points from a data file

OTHER
WKEBAILI_D01_2011-05-04-14h12m48s.txt: sample data file

removeInfinities: removes infinities from a data file so MATLAB can handle it

createZephyrFile: creates a data file from data points

removeOutliers: removes outliers from heat pulses

getVals: gets values of a field of a struct array

randpermarray: makes n copies of an array and randomly permutes the elements

ploterr: a function for plotting errors in x- and y-, written by Goetz Huesken
