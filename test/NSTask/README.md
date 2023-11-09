When test uses DYLD_INSERT=mulle-traceallocator.dylib, this will also inject
into other tools that are started by a test (via NSTask). But these may not
be mulle-allocator bases, and so dyld will not be happy.
