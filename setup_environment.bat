rem Get the EDM installer so that we can manage python packages ourselves 
curl https://package-data.enthought.com/edm/win_x86_64/2.0/edm_2.0.0_x86_64.msi -o %userprofile%\Downloads\edm_2.0.0_x86_64.msi

rem run enthought distribution manager installer
%userprofile%\Downloads\edm_2.0.0_x86_64.msi

rem make a new env using the python packaging that comes with amira
edm envs import --force -f "C:\Program Files\Amira-2019.2\python\bundles\3dSoftware_win64.json" hxEnv

rem install zarr and numcodecs and dependencies
edm run -e hxEnv pip install zarr numcodecs olefile et_xmlfile

rem tell amira to use the python we just installed
setx HX_FORCE_PYTHON_PATH %userprofile%\.edm\envs\hxEnv

echo Success