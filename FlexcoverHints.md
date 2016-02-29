# Flexcover Usage Hints #

## No coverage information shown when relative paths used on command line ([Bug 14](https://code.google.com/p/flexcover/issues/detail?id=4)) ##

If you are passing in filenames on the commandline to Flexcover, they **must** use absolute pathnames due to some unanticipated trickiness with AIR's handling of relative pathnames.  Relative pathnames don't work! In other words, do this:

```
   CoverageViewer.exe -output c:/coverage/output.xml c:/coverage/ProjectX/bin/ProjectX.cvm
```

and not this:


```
   cd c:/coverage
   CoverageViewer.exe -output output.xml ProjectX/bin/ProjectX.cvm
```

## "Not an SDK Directory" error in Flex Builder ##

If you modify an unpacked Flex SDK as directed in the install instructions, and then see an error message in Flex Builder that claims the resulting SDK directory is "not an SDK", the most likely reason is that you used the MacOS Finder or Windows Explorer to copy the modified SDK folders, and did so in a way that caused the complete replacement of the destination folders.  Sticking with `copy` or `cp` on the command line will help avoid this problem, as in:

```
   cp ./sdk-modifications/* /Applications/Flexcover-sdk/
```

## OutOfMemoryError during compilation ##

The Flexcover versions of mxmlc and compc are a little more memory-hungry than the originals.  If your compile in Ant is failing in java with an OutOfMemoryError, try including the 'fork' and 'maxmemory' attribute in your compilation task, for example:

```
   <mxmlc fork="true" maxmemory="512m" ...>
       ...
   </mxmlc>
```


## Automating Coverage Tests ##

It is possible to automate coverage measurements from unit test suites with flexcover -- it is a very important capability.  In order to do so, you need to do the following:

1. start the CoverageViewer app from Ant and pass the `.cvm` file on the command line, plus the `-output` option to specify the `.cvr` file to which the report will be written.  i.e.:

```
    CoverageViewer myProject.cvm -output myProject.cvr
```

2. have the unit tests call `CoverageManager.exit()` when they are done, rather than `System.exit()` or `fscommand("quit")`.  If you're using flexunit2 or Antennae's test runner, you will need to change the code in the TestResultPrinter class to make this change.  This ensures that all coverage data is flushed correctly before the program terminates.  It also causes the CoverageViewer to write the output file and terminate itself when it receives the information that the instrumented app has terminated.