# Amira Python Extensions

Python script plugins for [Thermo Scientific Amira-Avizo 3D](https://www.thermofisher.com/amira-avizo) that add support for reading and writing Zarr.

## Project structure

```
src/extensions/
├── zarr/   ZarrRead, ZarrWrite  — OME-NGFF / Zarr v2 and v3
├── n5/     N5Read, N5Write      — N5 containers (outdated, needs refactor)
```

Each extension consists of two files: a `.pyscro` (Python script) and a `.rc` (resource/registration) file.

## Installation

### Requirements

- Thermo Scientific Amira-Avizo 3D, version 2024.2 or higher (latest installed version is detected automatically) 
- [Enthought Deployment Manager (EDM)](https://www.enthought.com/edm/) installed at the default location

### Steps

#### 1. Create an EDM environment inside Amira

This step has to be done through the Amira GUI because it requires interactive authentication with Enthought, which is needed to access the `ThermoScientific/3dSoftware` package repository.

1. Launch Amira.
2. From the menu bar, choose ** Developer → Python Environments → Create Python Environment**.
3. In the **Python Environment** section, click **Add** to create a new environment.
4. Give it a name (e.g. `hxEnv1`) and click **OK**.
6. Wait while Amira downloads and installs the base Python packages it needs. This can take several minutes.
7. Once it finishes, the environment appears in the dropdown. Leave Amira open or close it - the environment persists.

#### 2. Run the installer

1. Download `install_zarr_extensions.bat` from the [Releases](../../releases) page.
2. Double-click it and approve the UAC prompt so it runs as Administrator.
3. The script lists every EDM environment under `~/.edm/envs/` as a numbered menu. Type the number of the environment you created (e.g. `hxEnv1`) and press Enter.
4. The script will:
   - Find the latest Amira installation under `C:\Program Files\`
   - Install the additional Python packages: `zarr==3.1.5`, `numpy==1.26.4`, `ome-zarr-models==1.7`, `tensorstore==0.1.82`
   - Download the extension files from this repository and copy them to `<AmiraRoot>\share\python_script_objects\`

#### 3. Activate the environment in Amira

1. Open Amira.
2. From the menu bar, choose **Developer → Python Environments → Select Python Environment**.
3. Pick the environment you set up (e.g. `hxEnv1`) from the list.
4. Restart Amira so the new environment and extensions are loaded.

## Using the extensions

> **Note:** Amira does not allow plugin-based scripts to run without an existing data object. Before using any extension, open any data object first (e.g. one of Amira's built-in example datasets). Then right-click it in the Project View, go to **Python Scripts**, and select the extension you want.

### ZarrRead

Loads a Zarr array (v2 or v3) into Amira as a `HxUniformScalarField3`.

- Supports 3D and 4D arrays (4D: select a channel index)
- Reads OME-NGFF 0.4 and 0.5 metadata for voxel size, translation offset, and axis units
- Displays array shape and units in the Properties panel
- Supports partial loading via per-axis start/stop slice controls

Right-click a data object → Python Scripts → `ZarrRead` → Create. Use the Input Directory picker to select a Zarr array folder, then click **Load Zarr**.

### ZarrWrite

Saves an `HxUniformScalarField3` as a Zarr array with OME-NGFF multiscales metadata.

- Writes Zarr v2 or v3 (selectable)
- Voxel size and translation offset are read from Amira's `VoxelSize` and `PhysicalSize` ports
- Voxel unit is selectable: `nanometer`, `micrometer`, `millimeter`

Right-click a scalar field → Python Scripts → `ZarrWrite` → Create. Choose an output directory, format, and units, then click **Save Zarr**.
