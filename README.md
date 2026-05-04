# Amira Python Extensions

Python script plugins for [Thermo Scientific Amira-Avizo 3D](https://www.thermofisher.com/amira-avizo) that add support for reading and writing Zarr, N5, and HDF5 datasets.

## Project structure

```
src/extensions/
├── zarr/   ZarrRead, ZarrWrite  — OME-NGFF / Zarr v2 and v3
├── n5/     N5Read, N5Write      — N5 containers
└── h5/     H5Loader             — HDF5 files
```

Each extension consists of two files: a `.pyscro` (Python script) and a `.rc` (resource/registration) file.

## Installation

### Requirements

- Thermo Scientific Amira-Avizo 3D (latest installed version is detected automatically)
- [Enthought Deployment Manager (EDM)](https://www.enthought.com/edm/) installed at the default location

### Steps

1. Download `install_zarr_extensions.bat` from the [Releases](../../releases) page.
2. Double-click it.
3. Approve the UAC prompt to allow the script to run as Administrator.
4. The script will:
   - Find the latest Amira installation under `C:\Program Files\`
   - Create the `hxEnv1` EDM environment from Amira's bundled package specification (skipped if it already exists)
   - Install the required Python packages: `zarr==3.1.5`, `numpy==1.26.4`, `ome-zarr-models==1.7`, `tensorstore==0.1.82`
   - Download the extension files from this repository and copy them to `<AmiraRoot>\share\python_script_objects\`
   - Set the `HX_FORCE_PYTHON_PATH` environment variable to point Amira at the new environment
5. Restart Amira.

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
