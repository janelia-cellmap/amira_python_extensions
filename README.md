# Python and TCL scripts for amira plugins

These plugins add functionality to Amira (tested on Amira 2019.2). Each plugin is composed of two files: a $PLUGIN_NAME.rc file and a $PLUGIN_NAME.pyscro file. To use a plugin, copy both .rc and .pyscro into the $AMIRA_ROOT/share/python_script_objects/ directory before Amira starts up.

## `H5Loader` instructions
To load *.h5 files, first open some data. It can be anything, e.g. one of the example datasets. Next, right-click on the data object in the project view and look for the "Python Scripts" category.
Click on it and you should see `H5Loader` as one of the options. Click on `H5Loader`, then click `Create`. This should create a H5Loader object in the project view, which has an `Input File` property
visible in the `Properties` pane. Click on the `...` icon to the far right of the `Input File` text. This will trigger a file selection pop-up which you can use to find the `h5` file you wish to load.
Once you select that file, click `Apply` to load the file. The data from the file will appear in the Project view as a `Uniform-Scalar-Field*` object, which you can then manipulate as you wish. Note: at the moment, `H5Loader` only loads data from the `volumes/raw` array within whatever `h5` file you select as input. To change this, you can edit the relevant line in `H5Loader.pyscro`; ultimately I should add a gui element that enables loading arbitrary datasets within an hdf5 file.
