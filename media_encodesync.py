#!/usr/bin/python
# Script to reencode videos to mp4 and then rsync them down to Media Center

import os
import time
import subprocess
import sys

pid = str(os.getpid())
pidfile = "/Users/strangeluck/Scripts/media_encodesync.pid"

if os.path.isfile(pidfile):
    print "%s already exists, exiting" % pidfile
    sys.exit()
file(pidfile, 'w').write(pid)
try:
    fileList = []
    rootdir = "/Users/strangeluck/Media/RAW/"
    for root, subFolders, files in os.walk(rootdir):
        for file in files:
            theFile = os.path.join(root,file)
            fileName, fileExtension = os.path.splitext(theFile)
            if fileExtension.lower() in ('.avi', '.divx', '.flv', '.m4v', '.mkv', '.mov', '.mpg', '.mpeg', '.wmv'):
                print 'Adding',theFile
                fileList.append(theFile)

    runstr = '/Applications/HandBrakeCLI -i "{0}" -o "{1}"'

    print '=======--------======='

    while fileList:
        inFile = fileList.pop()
        fileName, fileExtension = os.path.splitext(inFile)
        outFile = fileName+'.mp4'
        mp4File = '/Users/strangeluck/Media/Videos/'+os.path.basename(outFile)
        print (mp4File)

        print 'Processing',inFile
        returncode  = subprocess.call(runstr.format(inFile,mp4File), shell=True)
        time.sleep(5)
        print 'Removing',inFile
        os.remove(inFile)
        
finally:
    os.unlink(pidfile)

# Call RSYNC
# Sync files to Media Center after encode is complete
cmd = "/usr/bin/rsync --remove-source-files -azvP /Users/strangeluck/Media/Videos/ /mnt/Videos/"
print cmd
p = subprocess.Popen(cmd, shell=True).wait()
