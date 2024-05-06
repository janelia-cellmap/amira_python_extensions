rem copy files from working directory to the amira folder
pushd %~dp0
set AMIRAROOT="C:\Program Files\Thermo Scientific Amira-Avizo3D 2021.1\"
set DESTFOLDER="share\python_script_objects\"
copy *.pyscro %AMIRAROOT%%DESTFOLDER% /y
copy *.rc %AMIRAROOT%%DESTFOLDER% /y
popd
