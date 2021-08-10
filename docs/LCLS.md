## LCLS 

We are discussing the directory and file structure used by the LCLS experiments and how to map it to RUCIO's scope and
file names.

## LCLS experiments, runs and file layout

At LCLS experiments are performed at the different instruments. An experiment typically last for a few and 200-300
experiments are performed per year. The data are owned by the experiment and only the members of an experiment have
access to it.

The data taking is grouped into _runs_ and for each run the data are written to many files in parallel. Files are
identified by a stream number and chunk number. If a file exceeds a size limit it is closed and a new file for
the same stream is opened incrementing the chunk number by one. The files are written to disk using the path:
  
     <prefix>/<instrument>/<experiment>/xtc/<filename>
     with <filename>:
     <experiment>-r<run-nr>-s<stream-id>-c<chunk-id>.xtc[2]

     LFN: /<instrument>/<experiment>/xtc/<filename>

The <prefix> is site specific but the path elements after the prefix are identical at each site.
The raw data are written to the *xtc* folder. For each raw data file one (LCLS-II) or two
(LCLS-I) index files are created that allow fast random access to the data. These files are written to
the _index/_ and _smd/_ sub-directories. The following example shows the files the would be created for the fictitious
experiment mfx12345 running at instrument mfx for run two, stream three and chunk 0:

    /reg/d/psdm/mfx/mfx12345/xtc/mfx12345-r2002-s03-c00.xtc
    /reg/d/psdm/mfx/mfx12345/xtc/smd/mfx12345-r0202-s03-c00.smd.xtc
    /reg/d/psdm/mfx/mfx12345/xtc/index/mfx12345-r2002-s03-c00.xtc.idx

For LCLS-I all three files are created for LCLS-II only the xtc and smd.xtc files are created.

### HDF5: hdf5 files

For some experiments the xtc files are filtered and converted to hdf5 files these files are created under
the _hdf5_ folder of an experiment:

    <prefix>/<instrument>/<experiment>/hdf5

The filenames have some format, typically containing the experiment name and run number but it is up
to users and therefore no assumptions can be made.  

### Tape replica

The xtc and hdf5 files are archived to tape (HPSS). For the xtc files two copies are created either both
at SLAC or one at SLAC and one at NERSC. The xtc and smd.xtc are archived but not the xtc.idx files. Files
are singly transferred to tape no bundling of small files into a bigger one is performed (but should be
considered).
For SLAC files are grouped into tape families using the instrument name and folder name (xtc, hdf5).
For example _/psdm/CXI/xtc_ is the family for all cxi xtc files and _/psdm/CXI/hdf5_ for hdf5 files.
This means that when a file is put on tape besides adding a prefix to a files LFN the experiment name
and folder name in the LFN have to be swapped e.g.:

    LFN: /mfx/mfx12345/xtc/mfx12345-r2002-s03-c00.xtc
    tape path: /psdm//mfx/xtc/mfx12345/mfx12345-r2002-s03-c00.xtc

At NERSC no such mapping is needed only a prefix is added (/home/p/psdatmgr/hpssprod/psdm) to the LFN.


## Mapping to RUCIO

The basic unit of transfer is the *run* not a single file. The first iteration uses the following mapping
of experiment runs/files to RUCIO names:

- Each experiment has it's own RUCUIO-scope with the experiment name as scope name.
- A container is created for xtc files.
- A dataset is created for each run and is attached to the xtc container
- Files are registered into RUCIO and are attached to the corresponding run-dataset 

The Following rucio commands describe the nameing scheme using rte01 as a experiment name.

```
% rucio-admin create scope rte01
% rucio add-container rte01:xtc
% rucio add-dataset tre01:xtc.run0001
% rucio attach rte01:xtc rte01:xtc.run0001
% register files e.g.:
  /cds/data/psdm/rte/rte01/xtc/rte02-r0001-s03-c00.xtc -> rte01:xtc.rte02-r0001-s03-c00.xtc
  /cds/data/psdm/rte/rte01/xtc/smd/rte02-r0001-s03-c00.smd.xtc -> rte01:xtc.rte02-r0001-s03-c00.smd.xtc
  /cds/data/psdm/rte/rte01/xtc/index/rte02-r0001-s03-c00.smd.xtc -> rte01:xtc.rte02-r0001-s03-c00.xtc.idx
  Using a flat name space in RUCIO (all files are below xtc).
% rucio attach rte01:xtc.run0001 rte01:xtc.file.rte01-r0001-s01-c00.xtc
```
