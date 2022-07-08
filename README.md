# MulleObjCOSFoundation

#### 💻 Platform-dependent classes and categories like NSTask, NSPipe

These classes build on **MulleObjCStandardFoundation** and provide OS-specific
functionality. This library also adds categories on NSString to deal with
the native C String encoding of the platform.

It builds differently on each platform.

> Note: a few tests may fail because of missing implementations.
>
> Ideally - maybe - this library should move all the OS-specifica into C
> libraries and then cease to exist.



#### Classes

Class                   | Description
------------------------|----------------------------------------
`NSBundle`              | Plugins and dynamic loading
`NSDirectoryEnumerator` | List folder contents of the filesystem
`NSFileHandle`          | Wrapper for file descriptors (open)
`NSFilemanager`         | Filesystem management, like file deletion
`NSPipe`                | Support for inter-process pipes
`NSProcessInfo`         | Access to the environment and arguments
`NSRunLoop`             | A wrapper around `select()` usually
`NSTask`                | Does vfork() and execvs() on Unix
`NSUserDefaults`        | Access to the program settings (registry)


### You are here

![Overview](overview.dot.svg)


## Install

See [foundation-developer](//github.com/MulleFoundation/foundation-developer) for
installation instructions.


## License

Parts of this library:

```
Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```


## Authors

[Nat!](//www.mulle-kybernetik.com/weblog) for
[Mulle kybernetiK](//www.mulle-kybernetik.com) and
[Codeon GmbH](//www.codeon.de)
[Christoper LLoyd](//www.objc.net/cjwl)


#### MEMO: WARUM KOMMEN DIE ÄNDERUNGEN NICHT AN

mulle-test kann nur mulle-craft aufrufen und weiss nix von den subprojects.
Die sind aber wie "dependencies" und werden dann dazugelinkt. Änderungen kriegt
man mit mulle-test clean nicht rein, man muss mulle-sde craft machen.
