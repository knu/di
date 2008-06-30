#!/usr/bin/env ruby
# -*- ruby -*-
#
# di.rb - a wrapper around diff(1)
#
# Copyright (c) 2008 Akinori MUSHA
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Id$

MYVERSION = "0.1.0"
MYREVISION = %w$Rev$[1]
MYDATE = %w$Date$[1]
MYNAME = File.basename($0)

CVS_EXCLUDE_GLOBS = %w(
  RCS SCCS CVS CVS.adm
  RCSLOG cvslog.* tags TAGS
  .make.state .nse_depinfo *~
  \#* .\#* ,* _$*
  *$ *.old *.bak *.BAK
  *.orig *.rej *.del-* *.a
  *.olb *.o *.obj *.so
  *.exe *.Z *.elc *.ln
  core .svn .git .bzr .hg
)

def main(args)
  parse_args!(args)

  diff_main($diff_from_files, $diff_to_files, $diff_flags)

  exit $status
end

def warn(*lines)
  lines.each { |line|
    STDERR.puts "#{MYNAME}: #{line}"
  }
end

def set_flag(flag, val)
  if flag.match(/^-[0-9]/)
    if !$diff_flags.empty?
      if $diff_flags[-1].sub!(/([0-9])$/, '\1' + val)
        return
      end
    end
    $diff_flags << flag
  end

  case val
  when false
    $diff_flags.reject! { |k,| k == flag }
  when true
    $diff_flags.reject! { |k,| k == flag }
    $diff_flags << flag
  else
    case flag
    when /^--/
      $diff_flags << "#{flag}=#{val}"
    else
      $diff_flags << "#{flag}#{val}"
    end
  end
end

def parse_args!(args)
  $diff_from_files = $diff_to_files = $diff_format =
    $diff_relative = $diff_no_cvs_exclude = $diff_no_ignore_cvs_lines = nil
  $diff_exclude = []
  $diff_include = []
  $diff_flags = []

  require 'optparse'

  usage = <<-"EOF"
usage: #{MYNAME} [flags] [files]
  EOF

  banner = <<-"EOF"
#{MYNAME} - a wrapper around diff(1)
  version #{MYVERSION} [revision #{MYREVISION}] (#{MYDATE})

#{usage}
  EOF

  opts = OptionParser.new(banner) { |opts|
    opts.on("--no-cvs-exclude",
      "* Include CVS excluded files and directories.") { |val|
      $diff_no_cvs_exclude = !val
    }

    opts.on("--no-ignore-cvs-lines",
      "* Do not ignore CVS keyword lines.") { |val|
      $diff_no_ignore_cvs_lines = !val
    }

    opts.on("-R", "--relative",
      "* Use relative path names.") { |val|
      $diff_relative = val
    }

    opts.on("-i", "--ignore-case",
      "Ignore case differences in file contents.") { |val|
      set_flag("-i", val)
    }

    opts.on("--[no-]ignore-file-name-case",
      "Ignore case when comparing file names.") { |val|
      set_flag("--ignore-file-name-case", val)
    }

    opts.on("-E", "--ignore-tab-expansion",
      "Ignore changes due to tab expansion.") { |val|
      set_flag("-E", val)
    }

    opts.on("-b", "--ignore-space-change",
      "Ignore changes in the amount of white space.") { |val|
      set_flag("-b", val)
    }

    opts.on("-w", "--ignore-all-space",
      "Ignore all white space.") { |val|
      set_flag("-w", val)
    }

    opts.on("-B", "--ignore-blank-lines",
      "Ignore changes whose lines are all blank.") { |val|
      set_flag("-B", val)
    }

    opts.on("-I RE", "--ignore-matching-lines=RE",
      "Ignore changes whose lines all match RE.") { |val|
      set_flag("-I", val)
    }

    opts.on("--strip-trailing-cr",
      "Strip trailing carriage return on input.") { |val|
      set_flag("--strip-trailing-cr", val)
    }

    opts.on("-a", "--text",
      "Treat all files as text.") { |val|
      set_flag("-a", val)
    }

    opts.on("-c[NUM]", "--context[=NUM]",
      "Output NUM (default 3) lines of copied context.") { |val|
      if val
        $diff_format = ['-C', String === val ? val : '3']
      end
    }

    opts.on("-C NUM",
      "Output NUM lines of copied context.") { |val|
      set_flag("-C", val)
      if val
        $diff_format = ['-C', val]
      end
    }

    opts.on("-u[NUM]", "--unified[=NUM]",
      "Output NUM (default 3) lines of unified context.") { |val|
      if val
        $diff_format = ['-U', String === val ? val : '3']
      end
    }

    opts.on("-U NUM",
      "Output NUM lines of unified context.") { |val|
      if val
        $diff_format = ['-U', val]
      end
    }

    opts.on("-L LABEL", "--label=LABEL",
      "Use LABEL instead of file name.") { |val|
      set_flag("-L", val)
    }

    opts.on("-p", "--show-c-function",
      "Show which C function each change is in.") { |val|
      set_flag("-p", val)
    }

    opts.on("-F RE", "--show-function-line=RE",
      "Show the most recent line matching RE.") { |val|
      set_flag("-F", val)
    }

    opts.on("-q", "--brief",
      "Output only whether files differ.") { |val|
      set_flag("-q", val)
    }

    opts.on("-e", "--ed",
      "Output an ed script.") { |val|
      if val
        $diff_format = ['-e', val]
      end
    }

    opts.on("--normal",
      "Output a normal diff.") { |val|
      if val
        $diff_format = ['--normal', val]
      end
    }

    opts.on("-n", "--rcs",
      "Output an RCS format diff.") { |val|
      if val
        $diff_format = ['-n', val]
      end
    }

    opts.on("-y", "--side-by-side",
      "Output in two columns.") { |val|
      if val
        $diff_format = ['-y', val]
      end
    }

    opts.on("-W NUM", "--width=NUM",
      "Output at most NUM (default 130) print columns.") { |val|
      set_flag("-W", val)
    }

    opts.on("--left-column",
      "Output only the left column of common lines.") { |val|
      set_flag("--left-column", val)
    }

    opts.on("--suppress-common-lines",
      "Do not output common lines.") { |val|
      set_flag("--suppress-common-lines", val)
    }

    opts.on("-D NAME", "--ifdef=NAME",
      "Output merged file to show `#ifdef NAME' diffs.") { |val|
      set_flag("-D", val)
    }

    opts.on("--old-group-format=GFMT",
      "Format old input groups with GFMT.") { |val|
      set_flag("--old-group-format", val)
    }

    opts.on("--new-group-format=GFMT",
      "Format new input groups with GFMT.") { |val|
      set_flag("--new-group-format", val)
    }

    opts.on("--unchanged-group-format=GFMT",
      "Format unchanged input groups with GFMT.") { |val|
      set_flag("--unchanged-group-format", val)
    }

    opts.on("--line-format=LFMT",
      "Format all input lines with LFMT.") { |val|
      set_flag("--line-format", val)
    }

    opts.on("--old-line-format=LFMT",
      "Format old input lines with LFMT.") { |val|
      set_flag("--old-line-format", val)
    }

    opts.on("--new-line-format=LFMT",
      "Format new input lines with LFMT.") { |val|
      set_flag("--new-line-format", val)
    }

    opts.on("--unchanged-line-format=LFMT",
      "Format unchanged input lines with LFMT.") { |val|
      set_flag("--unchanged-line-format", val)
    }

    opts.on("-l", "--paginate",
      "Pass the output through `pr' to paginate it.") { |val|
      set_flag("-l", val)
    }

    opts.on("-t", "--expand-tabs",
      "Expand tabs to spaces in output.") { |val|
      set_flag("-t", val)
    }

    opts.on("-T", "--initial-tab",
      "Make tabs line up by prepending a tab.") { |val|
      set_flag("-T", "--initial-tab", val)
    }

    opts.on("--tabsize=NUM",
      "Tab stops are every NUM (default 8) print columns.") { |val|
      set_flag("--tabsize", val)
    }

    opts.on("-r", "--recursive",
      "Recursively compare any subdirectories found.") { |val|
      set_flag("-r", val)
    }

    opts.on("-N", "--new-file",
      "Treat absent files as empty.") { |val|
      set_flag("-N", val)
    }

    opts.on("--unidirectional-new-file",
      "Treat absent first files as empty.") { |val|
      set_flag("--unidirectional-new-file", val)
    }

    opts.on("-s", "--report-identical-files",
      "Report when two files are the same.") { |val|
      set_flag("-s", val)
    }

    opts.on("-x PAT", "--exclude=PAT",
      "Exclude files that match PAT.") { |val|
      $diff_exclude << val
    }

    opts.on("-X FILE", "--exclude-from=FILE",
      "Exclude files that match any pattern in FILE.") { |val|
      if val == '-'
        $diff_exclude.concat(STDIN.read.split(/\n/))
      else
        $diff_exclude.concat(File.read(val).split(/\n/))
      end
    }

    opts.on("--include=PAT",
      "Do not exclude files that match PAT.") { |val|
      $diff_include << val
    }

    opts.on("-S FILE", "--starting-file=FILE",
      "Start with FILE when comparing directories.") { |val|
      set_flag("-S", val)
    }

    opts.on("--from-file=FILE1",
      "Compare FILE1 to all operands.  FILE1 can be a directory.") { |val|
      $diff_from_files = [val]
    }

    opts.on("--to-file=FILE2",
      "Compare all operands to FILE2.  FILE2 can be a directory.") { |val|
      $diff_to_files = [val]
    }

    opts.on("--horizon-lines=NUM",
      "Keep NUM lines of the common prefix and suffix.") { |val|
      set_flag("--horizon-lines", val)
    }

    opts.on("-d", "--minimal",
      "Try hard to find a smaller set of changes.") { |val|
      set_flag("-d", val)
    }

    opts.on("--speed-large-files",
      "Assume large files and many scattered small changes.") { |val|
      set_flag("--speed-large-files", val)
    }

    opts.on("-v", "--version",
      "Output version info.") { |val|
      set_flag("-v", val)
    }

    opts.on("--help",
      "Output this help.") { |val|
      print opts
      puts "", "Options without the [*] sign will be passed through to diff(1)."
      exit 0
    }
  }

  begin
    opts.parse('-N')
    opts.parse('-p')
    opts.parse!(args)

    $diff_format ||= ['-U', '3']
    set_flag(*$diff_format)

    unless $diff_no_ignore_cvs_lines
      opts.parse('--ignore-matching-lines=\$[A-Z][A-Za-z0-9][A-Za-z0-9]*\(:.*\)\{0,1\}\$')
    end
  rescue OptionParser::ParseError => e
    warn e, "Try `#{MYNAME} --help' for more information."
    exit 64
  rescue => e
    warn e
    exit 1
  end

  begin
    if $diff_from_files
      $diff_to_files ||= args.dup

      if $diff_to_files.empty?
        raise "missing operand"
      end
    elsif $diff_to_files
      $diff_from_files = args.dup

      if $diff_from_files.empty?
        raise "missing operand"
      end
    else
      if args.size < 2
        raise "missing operand"
      end

      if File.directory?(args[0])
        $diff_to_files   = args.dup
        $diff_from_files = $diff_to_files.slice!(0, 1)
      else
        $diff_from_files = args.dup
        $diff_to_files   = $diff_from_files.slice!(-1, 1)
      end
    end

    if $diff_from_files.size != 1 && $diff_to_files.size != 1
      raise "wrong number of files given"
    end
  rescue => e
    warn e, "Try `#{MYNAME} --help' for more information."
    exit 64
  end
end

def diff_main(from_files, to_files, flags)
  $status = 0

  from_files.each { |from_file|
    if File.directory?(from_file)
      to_files.each { |to_file|
        if File.directory?(to_file)
          if $diff_relative
            to_file = File.expand_path(from_file, to_file)
          end

          diff_dirs(from_file, to_file, flags)
        else
          if $diff_relative
            from_file = File.expand_path(to_file, from_file)
          else
            from_file = File.expand_path(File.basename(to_file), from_file)
          end

          diff_files(from_file, to_file, flags)
        end
      }
    else
      to_files.each { |to_file|
        if File.directory?(to_file)
          if $diff_relative
            to_file = File.expand_path(from_file, to_file)
          else
            to_file = File.expand_path(File.basename(from_file), to_file)
          end
        end

        diff_files(from_file, to_file, flags)
      }
    end
  }
end

def diff_files(file1, file2, flags)
  files = [file1, file2].flatten

  return 0 if files.any? { |file| diff_exclude?(file) }

  system *(['diff'] + flags + files)

  status = $? >> 8
  $status = status if $status < status

  return status
end

def diff_dirs(dir1, dir2, flags)
  require 'find'

  files1 = Dir.entries(dir1).reject { |file| diff_exclude?(file) }
  files2 = Dir.entries(dir2).reject { |file| diff_exclude?(file) }

  missing1 = files2 - files1
  missing2 = files1 - files2

  (files1 & files2).each { |file|
    file1 = File.join(dir1, file)
    file2 = File.join(dir2, file)

    files = []

    if File.directory?(file1)
      if File.directory?(file2) && !File.symlink?(file1) && !File.symlink?(file2)
        diff_dirs(file1, file2, flags)
      else
        missing1 << file2
        missing2 << file1
      end
    else
      if File.directory?(file2)
        missing1 << file2
        missing2 << file1
      else
        files << file1
      end
    end

    unless files.empty?
      diff_files(files, dir2, flags)
    end  
  }

  missing2.each { |file|
    file1 = File.join(dir1, file)
    file2 = File.join(dir2, file)

    if flags.include?('-N')
      diff_files(file1, file2, flags)
    else
      printf "Only in %s: %s\n", dir1, file
      $status = 1 if $status < 1
    end
  }

  missing1.each { |file|
    file1 = File.join(dir1, file)
    file2 = File.join(dir2, file)

    if flags.include?('-N')
      diff_files(file1, file2, flags)
    else
      printf "Only in %s: %s\n", dir2, file
      $status = 1 if $status < 1
    end
  }
end

def diff_exclude?(file)
  basename = File.basename(file)

  return false if $diff_include.any? { |pat|
    File.fnmatch(pat, basename, File::FNM_DOTMATCH)
  }

  return true if basename.match(/\A\.\.?\z/)

  return true if $diff_no_cvs_exclude && $diff_exclude.any? { |pat|
    File.fnmatch(pat, basename, File::FNM_DOTMATCH)
  }

  return true if CVS_EXCLUDE_GLOBS.any? { |pat|
    File.fnmatch(pat, basename, File::FNM_DOTMATCH)
  }

  return false
end

main(ARGV)
