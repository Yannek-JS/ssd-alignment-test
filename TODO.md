Things TO DO with the script.

It is a random sequence. It does not mean that the first item on the list will be deployed firstly.

1. Control an accuracy of data of JSON config file.
2. Forbid continuing the test when the chosen disk contains any partition. It might be allowed when --unsave parameter would be provided invoking the script.
3. Store the test results in the file, e.g. in log/ directory.
4. Control whether writing access is possible in directory log/ .
5. Forbid writing the first sectors of a disk.
6. Add another configuration parameters to JSON config file:
    - size of data (zeros)  writing to the tested disk. Partition size should be enumerated respectively to this value. Accuracy of this data should be controlled too.


