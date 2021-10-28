# Python and TCL scripts for amira plugins

These plugins add functionality to Amira (tested on Amira 3D 2021.1).  

Each plugin is composed of two files: a $PLUGIN_NAME.rc file and a $PLUGIN_NAME.pyscro file.  

To use a plugin, copy both .rc and .pyscro into the $AMIRA_ROOT/share/python_script_objects/ directory before Amira starts up. You can also run (as Administrator) `copy_files.bat`, by double clicking, to copy all the .rc and .pyscro files.

To setup the necessary python environment, run Command Prompt as Administrator. Copy and paste the following commands one at a time into the prompt:
```bash
curl https://package-data.enthought.com/edm/win_x86_64/2.0/edm_2.0.0_x86_64.msi -o %userprofile%\Downloads\edm_2.0.0_x86_64.msi

set logfile=%userprofile%\amira_python_extension_log.txt

%userprofile%\Downloads\edm_2.0.0_x86_64.msi >%logfile% 2>&1

%userprofile%\AppData\Local\Programs\Enthought\edm\edm.bat envs import --force -f "C:\Program Files\Thermo Scientific Amira-Avizo3D 2021.1\python\bundles\3dSoftware_win64.json" hxEnv >>%logfile% 2>&1

%userprofile%\AppData\Local\Programs\Enthought\edm\edm.bat run -e hxEnv pip install zarr numcodecs olefile et_xmlfile dask[array] >>%logfile% 2>&1

setx HX_FORCE_PYTHON_PATH %userprofile%\.edm\envs\hxEnv >>%logfile% 2>&1
```

Wait for each step to finish before proceeding to the next. Some may take several seconds.

Once completed, open Amira and switch the `Python > Environment` to the 'User Environment' `hxEnv` if not already selected.

Deprecated: Run `setup_window_environment.bat` by double clicking it. If this does not work, you may have to copy and paste the commands from `setup_window_environment.bat` one at a time into the Command Prompt (run as Administrator).

## `N5Read` instructions
To load datasets from an N5 container, first open some data. It can be anything, e.g. one of the example datasets. (This step is necessary because Amira does not allow plugin-based data loaders) 
Next, right-click on the data object in the project view and look for the "Python Scripts" category.  
Click on it and you should see `N5Read` as one of the options.  
Click on `N5Read`, then click `Create`.  
This should create a N5Read object in the project view, which has an `Input File` property visible in the `Properties` pane.  
Click on the `...` icon to the far right of the `Input File` text. This will trigger a file selection pop-up which you can use to find the  `N5` dataset you wish to load.  
Once you select that dataset, select a bounding box of data to load with the X,Y,Z selection areas click `Apply` to load the data. If your `N5` container has `resolution` and `offset` attributes, this information will be used by Amira to localize the bounding box of the data in real coordinates. Once loaded, the data will appear in the Project View as a `Uniform-Scalar-Field*` object, which you can then manipulate as you wish.  
