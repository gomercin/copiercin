CopierciN is a basic attempt to bring Copy&Paste functionality to iPhone. It actually is a copy/paste enabled text-editor which can import&export textual data between applications.

It can be downloaded to jailbroken iPhones with  2.x firmwares from Cydia, under BigBoss repository, in Utilities section.

More information is available at http://copiercin.gomercin.net


---


# How to compile CopierciN on iPhone using the Toolchain? #
Basically, just checkout the source code following the instructions in the source tab and "make".

If you had not class-dumped the headers, you might need some modified headers which can be found in the Downloads section. I put the headers for address book access and UIKit. Just put those folders into /var/include directory on your iPhone and retry. You might want to backup existing folders first.

## What is needed? ##
As I had stated before, I am really new to ObjC and you will probably see it when you look at the source code :) Every kind of improvement suggestions would be welcome. I might add you as a developer to this project and you can update the code yourself but I would feel more comfortable testing the modified code myself first.

Another thing is, it would be great if someone could make a XCode project so that it can be compiled on Mac's too. I think it requires some modifications before making it available for compiling using XCode, still I am not sure of it. I just got an old iBook and installed XCode myself but did not even try to port CopierciN to it yet :)

So, let's rock'n roll :P