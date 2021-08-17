# ssd-align-perf-test.sh

`ssd-align-perf-test.sh` is the bash script for testing purposes. It facilitates writing performance tests on SSD with different partition alignment settings. It uses `parted` to create a partition, a config JSON file to provide `parted` with different partition alignment settings, and `dd` to test writing performance.

<br />

**!!! WARNING !!!**

**The script destroys the content of a tested disk. Be careful using it. You may loose your data by mistake.**

**You use this script on your own responsibility !!!**

<br />

The script is on early development stage. Though it is fully functional, it still needs many improvements. List of the things that are to to is contained in `TODO.md` file.

As mentioned above, the script utilises the data from `config/script-params.json` file. The value of the key `parted` is an array that consists of sets of partition alignment data. You can modify pre-existing data or add your own sets.
The structure of the alignment data set is like below:
```
    {
        "align": "none",
        "unit": "MiB",
        "start_offset": 1,
        "end_offset": 5001
    }
```

where:

* `align` is --align option of parted. It may have following values: `none`, `minimal`, `optimal`
* `unit` is parted unit parameter that applies to the partition offsets (start and end)
* `start_offset` is `parted mkpart` command parameter START that defines the offset from the beginning of the disk where the new partition starts
* `end_offset` is a `parted mkpart` command parameter END that defines the offset from the beginning of the disk where the new partition ends

<br />

**Known issues:**

1. The script does not control accuracy of the data of JSON config file. Bear it in mind when you are modifying the content of this file.
2. The script accepts the first sector of a disk as a partition beginning that is not correct as the first sector is reserved for Master Boot Record.

Both the issues mentioned above are on TO DO list.

<br />

**Requirements:**

* Bash version > 4.0 (parameter expansion and mapfile command have been used in the script). To check your Bash version, run 
```bash --version```
* following packages must be installed: `jq`, `parted`
* following packages are required too, however, they are included in most of Linux distro configurations by default: `util-linux`, `coreutils`, `grep`, `sed`, `awk` 

<br />

Environment used for testing the script:

* Linux 3.10.0-1160.31.1.el7.x86_64 #1 SMP, PRETTY_NAME="CentOS Linux 7 (Core)"
* GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)
* dd (coreutils) 8.22
* parted (GNU parted) 3.1
* grep (GNU grep) 2.20
* sed (GNU sed) 4.2.2
* GNU Awk 4.0.2
* jq-1.6
* lsblk from util-linux 2.23.2

