"""Generate a suite of OME-Zarr test datasets for ZarrRead/ZarrWrite testing.

Covers 3D, 4D, and 5D arrays with various axis orders, in both Zarr v2
(OME-NGFF 0.4) and Zarr v3 (OME-NGFF 0.5) formats.

Each voxel value encodes its own (storage) coordinates so the loaded slabs
can be spot-checked by eye:

    value[i0, i1, ..., iN] = i0 * 100^(N-1) + i1 * 100^(N-2) + ... + iN

For example in a 5D (t, c, z, y, x) array, the voxel at (t=3, c=2, z=4, y=5, x=6)
holds the value 302040506. Each pair of decimal digits, left-to-right, is the
index along the corresponding storage axis. (Each axis must therefore be < 100,
which is easily satisfied with the small shapes used here.)

Usage:
    python make_test_zarr_datasets.py [OUTPUT_DIR]
    python make_test_zarr_datasets.py --help

Defaults to ~/zarr_test_data. Creates two sub-directories:
    <output_dir>/v2/   -- Zarr v2 / OME-NGFF 0.4
    <output_dir>/v3/   -- Zarr v3 / OME-NGFF 0.5
each containing one .zarr container per test case.

Requires: zarr >= 3.0, numpy, click. Tested with zarr 3.2.1.
"""
import shutil
from pathlib import Path

import click
import numpy as np
import zarr


# ---------------------------------------------------------------------------
# Test cases.
# Each case: name, shape (storage order), axes (list of (type, name) tuples,
# storage order), per-axis scale, per-axis translation.
# Optional include_axes=False omits the axes from metadata (tests fallback).
# ---------------------------------------------------------------------------
CASES = []


def coord_encoded_array(shape):
    """Return a uint32 array where every voxel value encodes its index tuple.

    value[i0, i1, ..., iN] = sum(i_k * 100^(N-k-1)).
    Requires every axis size < 100.
    """
    if any(s >= 100 for s in shape):
        raise ValueError('Coordinate encoding requires axes smaller than 100.')
    indices = np.indices(shape)
    out = np.zeros(shape, dtype=np.int64)
    ndim = len(shape)
    for k in range(ndim):
        out += indices[k] * (100 ** (ndim - 1 - k))
    return out.astype('uint32')


def make_axes_metadata(axes_spec):
    """Build the OME-NGFF axes list from (type, name) tuples."""
    out = []
    for ax_type, name in axes_spec:
        ax = {'name': name, 'type': ax_type}
        if ax_type == 'space':
            ax['unit'] = 'nanometer'
        elif ax_type == 'time':
            ax['unit'] = 'second'
        # channel: no unit
        out.append(ax)
    return out


def write_one(out_path, shape, axes_spec, scale, translation,
              zarr_format, include_axes):
    """Write a single .zarr container with one s0 array and multiscales attrs."""
    out_path = Path(out_path)
    if out_path.exists():
        shutil.rmtree(out_path)

    group = zarr.open_group(str(out_path), mode='w', zarr_format=zarr_format)

    data = coord_encoded_array(shape)
    chunks = tuple(min(s, 32) for s in shape)

    if zarr_format == 3:
        dim_names = [n for _, n in axes_spec] if include_axes else None
        arr = group.create_array(
            's0', shape=shape, dtype='uint32',
            chunks=chunks, dimension_names=dim_names,
        )
    else:
        arr = group.create_array(
            's0', shape=shape, dtype='uint32', chunks=chunks,
        )
    arr[:] = data

    multiscales_entry = {
        'name': 'test',
        'datasets': [{
            'path': 's0',
            'coordinateTransformations': [
                {'type': 'scale', 'scale': [float(s) for s in scale]},
                {'type': 'translation',
                 'translation': [float(t) for t in translation]},
            ],
        }],
        'coordinateTransformations': [
            {'type': 'scale', 'scale': [1.0] * len(shape)},
        ],
    }
    if include_axes:
        multiscales_entry['axes'] = make_axes_metadata(axes_spec)

    if zarr_format == 3:
        group.attrs.update({
            'ome': {'version': '0.5', 'multiscales': [multiscales_entry]},
        })
    else:
        multiscales_entry['version'] = '0.4'
        group.attrs.update({'multiscales': [multiscales_entry]})


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.argument(
    'output_dir',
    type=click.Path(file_okay=False, dir_okay=True, path_type=Path),
    default=Path.home() / 'zarr_test_data',
    required=False,
)
def main(output_dir):
    """Generate OME-Zarr test datasets under OUTPUT_DIR.

    Produces both Zarr v2 (OME-NGFF 0.4) and Zarr v3 (OME-NGFF 0.5) versions
    of every test case, under <output_dir>/v2/ and <output_dir>/v3/.

    OUTPUT_DIR defaults to ~/zarr_test_data.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    click.echo('Writing test datasets to {0}'.format(output_dir))

    for fmt_label, fmt_version in [('v2', 2), ('v3', 3)]:
        sub = output_dir / fmt_label
        sub.mkdir(exist_ok=True)
        click.echo('\n[{0}]'.format(fmt_label))
        for case in CASES:
            path = sub / (case['name'] + '.zarr')
            write_one(
                out_path=path,
                shape=case['shape'],
                axes_spec=case['axes'],
                scale=case['scale'],
                translation=case['translation'],
                zarr_format=fmt_version,
                include_axes=case.get('include_axes', True),
            )
            ax_repr = '-'.join(n for _, n in case['axes'])
            note = '' if case.get('include_axes', True) else '  (no axes metadata)'
            click.echo('  {0:18s} shape={1!s:18s} axes={2}{3}'.format(
                case['name'], case['shape'], ax_repr, note))

    click.echo('\nDone.')


if __name__ == '__main__':
    main()
