= di

* http://www.idaemons.org/projects/di/

== DESCRIPTION:

di - a wrapper around GNU diff(1)

== FEATURES:

The di(1) command wraps around GNU diff(1) to provide reasonable
default settings and some original features:

  - Ignore non-significant files, such as backup files, object files,
    VCS administration files, etc. a la rsync(1)'s --cvs-ignore
    option.

  - Ignore difference of lines containing RCS tags.

  - Output in unified format.

  - Perform recursive comparison.

  - Turn on some other useful options: -N -p -d.

  - Provide the way to negate any of the above options.

== SYNOPSIS:

Run di --help for help.

== REQUIREMENTS:

- Ruby 1.8.6 or later

- GNU diff(1)

== INSTALL:

gem install di

== LICENSE:

Copyright (c) 2008, 2009, 2010 Akinori MUSHA

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
