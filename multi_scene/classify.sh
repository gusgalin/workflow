#!/bin/bash

# This script runs the classification script for a given list of scenes.
# It is NOT designed to change the model parameters inside the YAML file,
# as they are not taken into account for this step

# List of scenes to be processed

scn_list="004057 004058 004061 004062 005057 005058 005059 005060 \
          005061 006058 006059 006060 006061 007058 007059 007060 \
          008058 008059 008060 009059"

# General setting: path to template, root dir, etc

yconfig=/projectnb/landsat/projects/Colombia/workflow/multi_scene/yatsm_config.yaml
algopath=/projectnb/landsat/projects/Colombia/classifiers
export ROOTDIR=/projectnb/landsat/projects/Colombia/images
njob=400

# Iterate over scenes

for s in $scn_list; do
    # Get path and row in short version
    pt=${s:2:1}
    rw=${s:4:2}

    # Export all relevant variables for the yaml file
    export INPUT=$ROOTDIR/$s/$pt$rw"_input.csv"
    export RESULTS=$ROOTDIR/$s/Results/M1/TSR
    export IMG=$ROOTDIR/$s/images
    #export TRAINING=$ROOTDIR/$s/images/Training1.tif
    
    # Change the start and end train date accordingly if using diff. training
    # 
    #if [ $s = "005058" ]; then 
    #    export TRAINSTART="2000-078"
    #    export TRAINEND="2001-032"
    #elif [ $s = "006058" ]; then 
    #    export TRAINSTART="2001-031"
    #    export TRAINEND="2003-013"
    #else
    #    echo "Date in conditions don't match those in the list"
    #    exit
    #fi

    # CD to classifiers folder
    cd /projectnb/landsat/projects/Colombia/logs/$pt$rw/M1
    

    # Run classification, verify algorithm being used
    for job in $(seq 1 $njob); do
        qsub -j y -V -N class$pt$rw"_"$job -b y \
         yatsm -v classify $yconfig $algopath/mergedtrain_859-658-558.pkl $job $njob 
        
    done
    
    # For debugging purposes
    #yatsm -v classify $yconfig $algopath/mergedtrain_859-658-558.pkl 1 $njob 
done 