## LCLS

We are discussing the directory and file structure used by the LCLS experiments and how
to map it to RUCIO's scope and file names.

## LCLS experiments and directory layout

At LCLS experiments are performed at different instruments. An experiment typically last
for a few days and 200-300 experiments are performed per year. The data are owned by the
experiment and only the members of an experiment have access to it.

The various data types are stored in a well defined directory hierarchy. The directory consists of a
**_prefix_**  followed by the **_instrument_** and **_experiment_** name and the directory name for the **_data type_**:

    <prefix>/<instrument>/<experiment>/<dataType>

The data types are:

*  **xtc**: raw data
*  **hdf5**: raw data processed and converted to hdf5 files
*  **usrdaq**: experiment specific data

The data-type directories have sub-directories. For the raw data (xtc) the sub-directories
are determined, whereas the _hdf5_ and _usrdaq_ directories can contain any number and depth
of sub-directories. This directory layout is used at all sites that process LCLS data
(PCDS, S3DF, NERSC), only the **_prefix_** is site dependent (different storage resources within
a site also use different prefixes).
The path segment without the prefix, starting with the instrument name, is the logical file name (LFN)
and it is the same at every site.

The following shows an example of directories and file names for an experiment (fictious) using
prefix=_/cds/data/psdm_, instrument=_mfx_ and experiment=_mfx12345_:

      /cds/data/psdm/mfx/mfx12345/xtc/mfx12345-r2002-s03-c00.xtc
      /cds/data/psdm/mfx/mfx12345/xtc/mfx12345-r2001-s01-c00.xtc
      /cds/data/psdm/mfx/mfx12345/xtc/smalldata/mfx12345-r2001-s01-c00.smd.xtc
      /cds/data/psdm/mfx/mfx12345/xtc/smalldata/mfx12345-r2002-s03-c00.smd.xtc

      /cds/data/psdm/mfx/mfx12345/hdf5/mfx12345-r2002.h5
      /cds/data/psdm/mfx/mfx12345/hdf5/smalldata/mfx12345-r0122_roi0.h5
      /cds/data/psdm/mfx/mfx12345/hdf5/smalldata/integrate/test1/integrate_spectrum.h5

      /cds/data/psdm/mfx/mfx12345/usrdaq/lecroy/run491_ABEFGHIJch2.txt

### Raw data (xtc)
The data taking is grouped into _runs_ and for each run the data are written to many files in parallel. Files are
identified by a stream number and chunk number. If a file exceeds a size limit it is closed and a new file for
the same stream is opened incrementing the chunk number by one. The files are written to the _xtc_ directory as
descibed above. The file nameing format is:

     <experiment>-r<run-nr>-s<stream-id>-c<chunk-id>.xtc[2]

The DAQ writes also index files that allow fast filtering and random access to the data. For every raw data file one
index file (smd.xtc) is create for LCLS-II experiments and two index files (smd.xtc and xtc.idx) are created for LCLS-I
experiments. The smd.xtc files are written to the _smalldata_ sub-directory and the xtc.idx one to the _index_ sub-directory.
The following example shows the files the would be created for experiment mfx12345 running at instrument mfx for run two,
stream three and four and chunk 0:

    /reg/d/psdm/mfx/mfx12345/xtc/mfx12345-r2002-s03-c00.xtc
    /reg/d/psdm/mfx/mfx12345/xtc/mfx12345-r2002-s04-c00.xtc
    /reg/d/psdm/mfx/mfx12345/xtc/smd/mfx12345-r0202-s03-c00.smd.xtc
    /reg/d/psdm/mfx/mfx12345/xtc/smd/mfx12345-r0202-s04-c00.smd.xtc
    /reg/d/psdm/mfx/mfx12345/xtc/index/mfx12345-r2002-s03-c00.xtc.idx
    /reg/d/psdm/mfx/mfx12345/xtc/index/mfx12345-r2002-s04-c00.xtc.idx

For data analysis all files of a run are needed and therefore the fundamental unit for replication is a run not single files.

### HDF5: hdf5 files

For some experiments the xtc files are filtered and converted to hdf5 files these files are created under
the _hdf5_ folder of an experiment:

    <prefix>/<instrument>/<experiment>/hdf5

The filenames have some format, typically containing the experiment name and run number but it is up
to users and therefore no assumptions can be made.

### Tape replica

The xtc and hdf5 files are archived to tape (HPSS). For the xtc files two copies are created either both
at SLAC or one at SLAC and one at NERSC. The xtc and smd.xtc are archived but not the xtc.idx files. Files
are individually transferred to tape, no bundling of small files into a bigger one is performed (but should be
considered).
For SLAC files are grouped into tape families using the instrument name and folder name (xtc, hdf5).
For example _/psdm/CXI/xtc_ is the family for all cxi xtc files and _/psdm/CXI/hdf5_ for hdf5 files.
This means that when a file is put on tape besides adding a prefix to a files LFN the experiment name
and folder name in the LFN have to be swapped e.g.:

    LFN: /mfx/mfx12345/xtc/mfx12345-r2002-s03-c00.xtc
    tape path: /psdm//mfx/xtc/mfx12345/mfx12345-r2002-s03-c00.xtc    (only at SALC)

At NERSC no such mapping is needed only a prefix is added (/home/p/psdatmgr/hpssprod/psdm) to the LFN.


## RUCIO for LCLS

Below is a list of task we expect RUCIO to handle:

- Files created be the DAQ are registered to RUCIO (not uploaded)
- RUCIO is replicating the files to the archive stores currently HPSS at SLAC and NERSC (cloud storage is also under consideration)
- Replicate/transfer runs to a remote site for processing
- restore runs from an archive. Optimize the restore:
  - bundling restore request to optimize tape mounts and seek
  - select from which archive to restore files depending on the destination
- Initially only xtc files are managed
- Handling HDF5 files needs some thought
  - User reprocess runs and creating new hdf5 files but using the same filename.

## Mapping to RUCIO

As mentioned before hhe basic unit of transfer is the *run* not a single file.
In this section we discuss who to map the LCLS files/file-types/runs to RUCIO filename/datasets/container.
The initial idea is the following:

- Each experiment has it's own RUCUIO-scope with the experiment name as scope name (no instrument).
- xtc files in RUCIO are using the basename as file name, e.g.:
  - LCLS filename: /cds/data/psdm/rte/rte01/xtc/smd/rte02-r0001-s03-c00.smd.xtc
  - Rucio name: rte02-r0001-s03-c00.smd.xtc
- Datasets for xtc/run (each scope)

    Create one xtc dataset (or container) and a run dataset for each run.

    Either files are attached to the xtc and run data set, or a file is attached to a run dataset and the run dataset
    is attached to the xtc dataset.

    The difference might be how to query for files/runs and replication rules (e.g. a rule applied on
    a xtc container would apply to all files in the run container (in case files are only attached to run dataset.
