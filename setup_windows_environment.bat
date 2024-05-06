echo "Get the EDM installer so that we can manage python packages ourselves"
curl https://package-data.enthought.com/edm/win_x86_64/2.0/edm_2.0.0_x86_64.msi -o %userprofile%\Downloads\edm_2.0.0_x86_64.msi

set logfile=%userprofile%\amira_python_extension_log.txt

echo "run enthought distribution manager installer"
%userprofile%\Downloads\edm_2.0.0_x86_64.msi >%logfile% 2>&1

echo "make a new env using the python packaging that comes with amira"
%userprofile%\AppData\Local\Programs\Enthought\edm\edm.bat envs import --force -f "C:\Program Files\Thermo Scientific Amira-Avizo3D 2021.1\python\bundles\3dSoftware_win64.json" hxEnv >>%logfile% 2>&1

echo "install python packages"
%userprofile%\AppData\Local\Programs\Enthought\edm\edm.bat run -e hxEnv pip install zarr numcodecs olefile et_xmlfile dask[array] >>%logfile% 2>&1

echo "tell amira to use the python we just installed"
setx HX_FORCE_PYTHON_PATH %userprofile%\.edm\envs\hxEnv >>%logfile% 2>&1

echo Success