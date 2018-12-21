# MRGADWrapper
Wrapper for mrgad

## Description
  This wrapper will automatically run instance(s) of MRGAD. Must follow _CatWISE directory structure_.
    
## How to Run Modes
* Mode 1: Everything Mode
	* Run all tiles in input directory
	* **./mrgad_wrapper** 1 \<ParentDirectory\>
* Mode 2: List Mode
	* Run all tiles in input list
	* **./mrgad_wrapper** 2 \<ParentDirectory\> \<TileList\>
* Mode 3: Single-Tile Mode
	* Run tile given in command line input. The input TileName should be a RaDecID (eg 3568m182)
	* **./mrgad_wrapper** 3 \<ParentDirectory\> \<TileName\>
  
## Arguments
  * \-rsync
