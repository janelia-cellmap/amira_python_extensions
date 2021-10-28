# Python and TCL scripts for amira plugins

These plugins add functionality to Amira (tested on Amira 3D 2021.1).  

Each plugin is composed of two files: a $PLUGIN_NAME.rc file and a $PLUGIN_NAME.pyscro file.  

To use a plugin, copy both .rc and .pyscro into the $AMIRA_ROOT/share/python_script_objects/ directory before Amira starts up. You can also run (as Administrator) `copy_files.bat`, by double clicking, to copy all the .rc and .pyscro files.

To setup the necessary python environment, run (as Administrator) `setup_window_environment.bat` by double clicking it. Then in Amira, switch the `Python > Environment` to the 'User Environment' `hxEnv` if not already selected.

## `N5Read` instructions
To load datasets from an N5 container, first open some data. It can be anything, e.g. one of the example datasets. (This step is necessary because Amira does not allow plugin-based data loaders) 
Next, right-click on the data object in the project view and look for the "Python Scripts" category.  
Click on it and you should see `N5Read` as one of the options.  
Click on `N5Read`, then click `Create`.  
This should create a N5Read object in the project view, which has an `Input File` property visible in the `Properties` pane.  
Click on the `...` icon to the far right of the `Input File` text. This will trigger a file selection pop-up which you can use to find the  `N5` dataset you wish to load.  
Once you select that dataset, select a bounding box of data to load with the X,Y,Z selection areas click `Apply` to load the data. If your `N5` container has `resolution` and `offset` attributes, this information will be used by Amira to localize the bounding box of the data in real coordinates. Once loaded, the data will appear in the Project View as a `Uniform-Scalar-Field*` object, which you can then manipulate as you wish.  
