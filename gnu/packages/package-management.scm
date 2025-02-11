;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2015, 2017, 2020, 2021 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2017 Muriithi Frederick Muriuki <fredmanglis@gmail.com>
;;; Copyright © 2017, 2018 Oleg Pykhalov <go.wigust@gmail.com>
;;; Copyright © 2017 Roel Janssen <roel@gnu.org>
;;; Copyright © 2017–2021 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2018 Julien Lepiller <julien@lepiller.eu>
;;; Copyright © 2018, 2019 Rutger Helling <rhelling@mykolab.com>
;;; Copyright © 2018 Sou Bunnbu <iyzsong@member.fsf.org>
;;; Copyright © 2018, 2019 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2019, 2020, 2021 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2019 Jonathan Brielmaier <jonathan.brielmaier@web.de>
;;; Copyright © 2020 Mathieu Othacehe <m.othacehe@gmail.com>
;;; Copyright © 2020 Jan (janneke) Nieuwenhuizen <janneke@gnu.org>
;;; Copyright © 2020 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2020 Jesse Gibbons <jgibbons2357+guix@gmail.com>
;;; Copyright © 2020 Martin Becze <mjbecze@riseup.net>
;;; Copyright © 2020 Vincent Legoll <vincent.legoll@gmail.com>
;;; Copyright © 2021 Ivan Gankevich <i.gankevich@spbu.ru>
;;; Copyright © 2021 Maxim Cournoyer <maxim.cournoyer@gmail.com>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages package-management)
  #:use-module (gnu packages)
  #:use-module (gnu packages acl)
  #:use-module (gnu packages attr)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bdw-gc)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages bootstrap)          ;for 'bootstrap-guile-origin'
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages cpio)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages dejagnu)
  #:use-module (gnu packages dbm)
  #:use-module (gnu packages docbook)
  #:use-module (gnu packages file)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages hurd)
  #:use-module (gnu packages less)
  #:use-module (gnu packages libedit)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages man)
  #:use-module (gnu packages nettle)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages patchutils)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages perl-check)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages popt)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tcl)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages time)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages version-control)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1))

(define (boot-guile-uri arch)
  "Return the URI for the bootstrap Guile tarball for ARCH."
  (cond ((string=? "armhf" arch)
         (string-append "http://alpha.gnu.org/gnu/guix/bootstrap/"
                        arch "-linux"
                        "/20150101/guile-2.0.11.tar.xz"))
        ((string=? "aarch64" arch)
         (string-append "http://alpha.gnu.org/gnu/guix/bootstrap/"
                        arch "-linux/20170217/guile-2.0.14.tar.xz"))
        (else
         (string-append "http://alpha.gnu.org/gnu/guix/bootstrap/"
                        arch "-linux"
                        "/20131110/guile-2.0.9.tar.xz"))))

;; NOTE: The commit IDs used here form a linked list threaded through the git
;; history. In a phenomenon known as boot-stripping, not only the head of this
;; list is used, but also a few older versions, when a guix from this package is
;; used to build something also depending on guix.
;;
;; Therefore, if, by accident, you set this package to a non-existent commit ID,
;; it is insufficient to simply correct it with the latest commit.
;; Instead, please push one commit that rolls back Guix to before the mistake,
;; and then another that points to the first one. That way, the faulty commit
;; won't appear on the linked list.
(define-public guix
  ;; Latest version of Guix, which may or may not correspond to a release.
  ;; Note: the 'update-guix-package.scm' script expects this definition to
  ;; start precisely like this.
  (let ((version "1.3.0")
        (commit "c3c502896b1454b345ee9f17d20063853652a35a")
        (revision 10))
    (package
      (name "guix")

      (version (if (zero? revision)
                   version
                   (string-append version "-"
                                  (number->string revision)
                                  "." (string-take commit 7))))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://git.savannah.gnu.org/git/guix.git")
                      (commit commit)))
                (sha256
                 (base32
                  "037nlr5z8qmq2zp0slcg5lyhcdp7v6vxl1f36wkqrw9xzgq8k6kf"))
                (file-name (string-append "guix-" version "-checkout"))))
      (build-system gnu-build-system)
      (arguments
       `(#:configure-flags (list

                            ;; Provide channel metadata for 'guix describe'.
                            ;; Don't pass '--with-channel-url' and
                            ;; '--with-channel-introduction' and instead use
                            ;; the defaults.
                            ,(string-append "--with-channel-commit=" commit)

                            "--localstatedir=/var"
                            "--sysconfdir=/etc"
                            (string-append "--with-bash-completion-dir="
                                           (assoc-ref %outputs "out")
                                           "/etc/bash_completion.d")

                            ;; Set 'DOT_USER_PROGRAM' to the empty string so
                            ;; we don't keep a reference to Graphviz, whose
                            ;; closure is pretty big (too big for the Guix
                            ;; system installation image.)
                            "ac_cv_path_DOT_USER_PROGRAM=dot"

                            ;; To avoid problems with the length of shebangs,
                            ;; choose a fixed-width and short directory name
                            ;; for tests.
                            "ac_cv_guix_test_root=/tmp/guix-tests"
                            ,@(if (hurd-target?) '("--with-courage") '()))
         #:parallel-tests? #f         ;work around <http://bugs.gnu.org/21097>

         #:modules ((guix build gnu-build-system)
                    (guix build utils)
                    (srfi srfi-26)
                    (ice-9 popen)
                    (ice-9 rdelim))

         #:phases (modify-phases %standard-phases
                    (replace 'bootstrap
                      (lambda _
                        ;; Make sure 'msgmerge' can modify the PO files.
                        (for-each (lambda (po)
                                    (chmod po #o666))
                                  (find-files "." "\\.po$"))

                        (patch-shebang "build-aux/git-version-gen")

                        (call-with-output-file ".tarball-version"
                          (lambda (port)
                            (display ,version port)))

                        ;; Install SysV init files to $(prefix)/etc rather
                        ;; than to /etc.
                        (substitute* "nix/local.mk"
                          (("^sysvinitservicedir = .*$")
                           (string-append "sysvinitservicedir = \
$(prefix)/etc/init.d\n")))

                        ;; Install OpenRC init files to $(prefix)/etc rather
                        ;; than to /etc.
                        (substitute* "nix/local.mk"
                          (("^openrcservicedir = .*$")
                           (string-append "openrcservicedir = \
$(prefix)/etc/openrc\n")))

                        (invoke "sh" "bootstrap")))
                    (add-before 'build 'use-host-compressors
                      (lambda* (#:key inputs target #:allow-other-keys)
                        (when target
                          ;; Use host compressors.
                          (let ((bzip2 (assoc-ref inputs "bzip2"))
                                (gzip (assoc-ref inputs "gzip"))
                                (xz (assoc-ref inputs "xz")))
                            (substitute* "guix/config.scm"
                              (("\"[^\"]*/bin/bzip2")
                               (string-append "\"" bzip2 "/bin/bzip2"))
                              (("\"[^\"]*/bin/gzip") gzip
                               (string-append "\"" gzip "/bin/gzip"))
                              (("\"[^\"]*/bin//xz")
                               (string-append "\"" xz "/bin/xz")))))
                        #t))
                    (add-before 'check 'copy-bootstrap-guile
                      (lambda* (#:key system target inputs #:allow-other-keys)
                        ;; Copy the bootstrap guile tarball in the store
                        ;; used by the test suite.
                        (define (intern file recursive?)
                          ;; Note: don't use 'guix download' here because we
                          ;; need to set the 'recursive?' argument.
                          (define base
                            (strip-store-file-name file))

                          (define code
                            `(begin
                               (use-modules (guix))
                               (with-store store
                                 (let* ((item (add-to-store store ,base
                                                            ,recursive?
                                                            "sha256" ,file))
                                        (root (string-append "/tmp/gc-root-"
                                                             (basename item))))
                                   ;; Register a root so that the GC tests
                                   ;; don't delete those.
                                   (symlink item root)
                                   (add-indirect-root store root)))))

                          (invoke "./test-env" "guile" "-c"
                                  (object->string code)))

                        (unless target
                          (intern (assoc-ref inputs "boot-guile") #f)

                          ;; On x86_64 some tests need the i686 Guile.
                          (when (and (not target)
                                     (string=? system "x86_64-linux"))
                            (intern (assoc-ref inputs "boot-guile/i686") #f))

                          ;; Copy the bootstrap executables.
                          (for-each (lambda (input)
                                      (intern (assoc-ref inputs input) #t))
                                    '("bootstrap/bash" "bootstrap/mkdir"
                                      "bootstrap/tar" "bootstrap/xz")))
                        #t))
                    (add-after 'unpack 'disable-failing-tests
                      ;; XXX FIXME: These tests fail within the build container.
                      (lambda _
                        (substitute* "tests/syscalls.scm"
                          (("^\\(test-(assert|equal) \"(clone|setns|pivot-root)\"" all)
                           (string-append "(test-skip 1)\n" all)))
                        (substitute* "tests/containers.scm"
                          (("^\\(test-(assert|equal)" all)
                           (string-append "(test-skip 1)\n" all)))
                        (when (file-exists? "tests/guix-environment-container.sh")
                          (substitute* "tests/guix-environment-container.sh"
                            (("guix environment --version")
                             "exit 77\n")))
                        #t))
                    (add-before 'check 'set-SHELL
                      (lambda _
                        ;; 'guix environment' tests rely on 'SHELL' having a
                        ;; correct value, so set it.
                        (setenv "SHELL" (which "sh"))
                        #t))
                    (add-after 'install 'wrap-program
                      (lambda* (#:key inputs native-inputs outputs target
                                #:allow-other-keys)
                        ;; Make sure the 'guix' command finds GnuTLS,
                        ;; Guile-JSON, and Guile-Git automatically.
                        (let* ((out    (assoc-ref outputs "out"))
                               (guile  (assoc-ref (or native-inputs inputs)
                                                  "guile"))
                               (avahi  (assoc-ref inputs "guile-avahi"))
                               (gcrypt (assoc-ref inputs "guile-gcrypt"))
                               (guile-lib   (assoc-ref inputs "guile-lib"))
                               (json   (assoc-ref inputs "guile-json"))
                               (sqlite (assoc-ref inputs "guile-sqlite3"))
                               (zlib   (assoc-ref inputs "guile-zlib"))
                               (lzlib  (assoc-ref inputs "guile-lzlib"))
                               (zstd   (assoc-ref inputs "guile-zstd"))
                               (git    (assoc-ref inputs "guile-git"))
                               (bs     (assoc-ref inputs
                                                  "guile-bytestructures"))
                               (ssh    (assoc-ref inputs "guile-ssh"))
                               (gnutls (assoc-ref inputs "gnutls"))
                               (disarchive (assoc-ref inputs "disarchive"))
                               (locales (assoc-ref inputs "glibc-utf8-locales"))
                               (deps   (list gcrypt json sqlite gnutls git
                                             bs ssh zlib lzlib zstd guile-lib
                                             disarchive))
                               (deps*  (if avahi (cons avahi deps) deps))
                               (effective
                                (read-line
                                 (open-pipe* OPEN_READ
                                             (string-append guile "/bin/guile")
                                             "-c" "(display (effective-version))")))
                               (path   (map (cut string-append <>
                                                 "/share/guile/site/"
                                                 effective)
                                            (delete #f deps*)))
                               (gopath (map (cut string-append <>
                                                 "/lib/guile/" effective
                                                 "/site-ccache")
                                            (delete #f deps*)))
                               (locpath (string-append locales "/lib/locale")))

                          ;; Modify 'guix' directly instead of using
                          ;; 'wrap-program'.  This avoids the indirection
                          ;; through Bash, which in turn avoids getting Bash's
                          ;; own locale warnings.
                          (substitute* (string-append out "/bin/guix")
                            (("!#")
                             (string-append
                              "!#\n\n"
                              (object->string
                               `(set! %load-path (append ',path %load-path)))
                              "\n"
                              (object->string
                               `(set! %load-compiled-path
                                  (append ',gopath %load-compiled-path)))
                              "\n"
                              (object->string
                               `(let ((path (getenv "GUIX_LOCPATH")))
                                  (setenv "GUIX_LOCPATH"
                                          (if path
                                              (string-append path ":" ,locpath)
                                              ,locpath))))
                              "\n\n"))))))

                    ;; The 'guix' executable has 'OUT/libexec/guix/guile' as
                    ;; its shebang; that should remain unchanged, thus remove
                    ;; the 'patch-shebangs' phase, which would otherwise
                    ;; change it to 'GUILE/bin/guile'.
                    (delete 'patch-shebangs))))
      (native-inputs `(("pkg-config" ,pkg-config)

                       ;; Guile libraries are needed here for
                       ;; cross-compilation.
                       ("guile" ,guile-3.0-latest) ;for faster builds
                       ("gnutls" ,gnutls)
                       ,@(if (%current-target-system)
                             '()
                             `(("guile-avahi" ,guile-avahi)))
                       ("guile-gcrypt" ,guile-gcrypt)
                       ("guile-json" ,guile-json-4)
                       ("guile-lib" ,guile-lib)
                       ("guile-sqlite3" ,guile-sqlite3)
                       ("guile-zlib" ,guile-zlib)
                       ("guile-lzlib" ,guile-lzlib)
                       ("guile-zstd" ,guile-zstd)
                       ("guile-ssh" ,guile-ssh)
                       ("guile-git" ,guile-git)

                       ;; XXX: Keep the development inputs here even though
                       ;; they're unnecessary, just so that 'guix environment
                       ;; guix' always contains them.
                       ("autoconf" ,autoconf)
                       ("automake" ,automake)
                       ("gettext" ,gettext-minimal)
                       ("texinfo" ,texinfo)
                       ("graphviz" ,graphviz)
                       ("help2man" ,help2man)
                       ("po4a" ,po4a)))
      (inputs
       `(("bzip2" ,bzip2)
         ("gzip" ,gzip)
         ("sqlite" ,sqlite)
         ("libgcrypt" ,libgcrypt)

         ("guile" ,guile-3.0-latest)

         ;; Some of the tests use "unshare" when it is available.
         ("util-linux" ,util-linux)

         ;; Many tests rely on the 'guile-bootstrap' package, which is why we
         ;; have it here.
         ("boot-guile" ,(bootstrap-guile-origin (%current-system)))
         ,@(if (and (not (%current-target-system))
                    (string=? (%current-system) "x86_64-linux"))
               `(("boot-guile/i686" ,(bootstrap-guile-origin "i686-linux")))
               '())
         ,@(if (%current-target-system)
               `(("xz" ,xz))
               '())

         ;; Tests also rely on these bootstrap executables.
         ("bootstrap/bash" ,(bootstrap-executable "bash" (%current-system)))
         ("bootstrap/mkdir" ,(bootstrap-executable "mkdir" (%current-system)))
         ("bootstrap/tar" ,(bootstrap-executable "tar" (%current-system)))
         ("bootstrap/xz" ,(bootstrap-executable "xz" (%current-system)))

         ("disarchive" ,disarchive)               ;for 'guix perform-download'

         ("glibc-utf8-locales" ,glibc-utf8-locales)))
      (propagated-inputs
       `(("gnutls" ,gnutls)
         ;; Avahi requires "glib" which doesn't cross-compile yet.
         ,@(if (%current-target-system)
               '()
               `(("guile-avahi" ,guile-avahi)))
         ("guile-gcrypt" ,guile-gcrypt)
         ("guile-json" ,guile-json-4)
         ("guile-lib" ,guile-lib)
         ("guile-sqlite3" ,guile-sqlite3)
         ("guile-ssh" ,guile-ssh)
         ("guile-git" ,guile-git)
         ("guile-zlib" ,guile-zlib)
         ("guile-lzlib" ,guile-lzlib)
         ("guile-zstd" ,guile-zstd)))
      (native-search-paths
       (list (search-path-specification
              (variable "GUIX_EXTENSIONS_PATH")
              (files '("share/guix/extensions")))

             ;; (guix git) and (guix build download) honor this variable whose
             ;; name comes from OpenSSL.
             (search-path-specification
              (variable "SSL_CERT_DIR")
              (separator #f)                      ;single entry
              (files '("etc/ssl/certs")))))

      (home-page "https://www.gnu.org/software/guix/")
      (synopsis "Functional package manager for installed software packages and versions")
      (description
       "GNU Guix is a functional package manager for the GNU system, and is
also a distribution thereof.  It includes a virtual machine image.  Besides
the usual package management features, it also supports transactional
upgrades and roll-backs, per-user profiles, and much more.  It is based on
the Nix package manager.")
      (license license:gpl3+)
      (properties '((ftp-server . "alpha.gnu.org"))))))

(define-public guix-daemon
  ;; This package is for internal consumption: it allows us to quickly build
  ;; the 'guix-daemon' program and use that in (guix self), used by 'guix
  ;; pull'.
  (package
    (inherit guix)
    (properties `((hidden? . #t)))
    (name "guix-daemon")

    ;; Use a minimum set of dependencies.
    (native-inputs
     (fold alist-delete (package-native-inputs guix)
           '("po4a" "graphviz" "help2man")))
    (inputs
     `(("gnutls" ,gnutls)
       ("guile-git" ,guile-git)
       ("guile-json" ,guile-json-3)
       ("guile-gcrypt" ,guile-gcrypt)
       ,@(fold alist-delete (package-inputs guix)
               '("boot-guile" "boot-guile/i686" "util-linux"))))

    (propagated-inputs '())

    (arguments
     (substitute-keyword-arguments (package-arguments guix)
       ((#:configure-flags flags '())
        ;; Pretend we have those libraries; we don't actually need them.
        `(append ,flags
                 '("guix_cv_have_recent_guile_sqlite3=yes"
                   "guix_cv_have_recent_guile_ssh=yes")))
       ((#:tests? #f #f)
        #f)
       ((#:phases phases '%standard-phases)
        `(modify-phases ,phases
           (add-after 'unpack 'change-default-guix
             (lambda _
               ;; We need to tell 'guix-daemon' which 'guix' command to use.
               ;; Here we use a questionable hack where we hard-code root's
               ;; current guix, which could be wrong (XXX).  Note that scripts
               ;; like 'guix perform-download' do not run as root so we assume
               ;; that they have access to /var/guix/profiles/per-user/root.
               (substitute* "nix/libstore/globals.cc"
                 (("guixProgram = (.*)nixBinDir + \"/guix\"" _ before)
                  (string-append "guixProgram = " before
                                 "/var/guix/profiles/per-user/root\
/current-guix/bin/guix")))
               #t))
           (replace 'build
             (lambda _
               (invoke "make" "nix/libstore/schema.sql.hh")
               (invoke "make" "-j" (number->string
                                    (parallel-job-count))
                       "guix-daemon")))
           (delete 'copy-bootstrap-guile)
           (replace 'install
             (lambda* (#:key outputs #:allow-other-keys)
               (invoke "make" "install-binPROGRAMS")))
           (delete 'wrap-program)))))))

(define-public guile3.0-guix
  (deprecated-package "guile3.0-guix" guix))

(define-public guix-minimal
  ;; A version of Guix which is built with the minimal set of dependencies, as
  ;; outlined in the README "Requirements" section.  Intended as a CI job, so
  ;; marked as hidden.
  (hidden-package
   (package
     (inherit guix)
     (name "guix-minimal")
     (native-inputs
      (fold alist-delete
            (package-native-inputs guix)
            '("guile-ssh")))
     (propagated-inputs
      (fold alist-delete
            (package-propagated-inputs guix)
            '("guile-ssh"))))))

(define (source-file? file stat)
  "Return true if FILE is likely a source file, false if it is a typical
generated file."
  (define (wrong-extension? file)
    (or (string-suffix? "~" file)
        (member (file-extension file)
                '("o" "a" "lo" "so" "go"))))

  (match (basename file)
    ((or ".git" "autom4te.cache" "configure" "Makefile" "Makefile.in" ".libs")
     #f)
    ((? wrong-extension?)
     #f)
    (_
     #t)))

(define-public current-guix-package
  ;; This parameter allows callers to override the package that 'current-guix'
  ;; returns.  This is useful when 'current-guix' cannot compute it by itself,
  ;; for instance because it's not running from a source code checkout.
  (make-parameter #f))

(define-public current-guix
  (let* ((repository-root (delay (canonicalize-path
                                  (string-append (current-source-directory)
                                                 "/../.."))))
         (select? (delay (or (git-predicate (force repository-root))
                             source-file?))))
    (lambda ()
      "Return a package representing Guix built from the current source tree.
This works by adding the current source tree to the store (after filtering it
out) and returning a package that uses that as its 'source'."
      (or (current-guix-package)
          (package
            (inherit guix)
            (version (string-append (package-version guix) "+"))
            (source (local-file (force repository-root) "guix-current"
                                #:recursive? #t
                                #:select? (force select?))))))))


;;;
;;; Other tools.
;;;

(define-public nix
  (package
    (name "nix")
    (version "2.3.16")
    (source (origin
             (method url-fetch)
             (uri (string-append "https://releases.nixos.org/nix/nix-"
                                 version "/nix-" version ".tar.xz"))
             (sha256
              (base32
               "1g5aqavr6i3c1xln53w1pdh1kvlxrpnknb105m4jbd85kyv83rky"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags '("--sysconfdir=/etc" "--enable-gc")
       #:phases
       (modify-phases %standard-phases
         (replace 'install
           ;; Don't try & fail to create subdirectories in /etc, but keep them
           ;; in the output as examples.
           (lambda* (#:key (make-flags '()) outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (etc (string-append out "/etc")))
               (apply invoke "make" "install"
                      (string-append "sysconfdir=" etc)
                      (string-append "profiledir=" etc "/profile.d")
                      make-flags)))))))
    (native-inputs `(("pkg-config" ,pkg-config)))
    (inputs `(("boost" ,boost)
              ("brotli" ,brotli)
              ("bzip2" ,bzip2)
              ("curl" ,curl)
              ("editline" ,editline)
              ("libgc" ,libgc)
              ("libseccomp" ,libseccomp)
              ("libsodium" ,libsodium)
              ("openssl" ,openssl)
              ("sqlite" ,sqlite)
              ("xz" ,xz)))
    (home-page "https://nixos.org/nix/")
    (synopsis "The Nix package manager")
    (description
     "Nix is a purely functional package manager.  This means that it treats
packages like values in purely functional programming languages such as
Haskell—they are built by functions that don't have side-effects, and they
never change after they have been built.  Nix stores packages in the Nix
store, usually the directory /nix/store, where each package has its own unique
sub-directory.")
    (license license:lgpl2.1+)))

(define-public stow
  (package
    (name "stow")
    (version "2.3.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnu/stow/stow-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "0jrxy12ywn7smdzdnvwzjw77l6knx6jkj2rckgykg1dpf6bdkm89"))))
    (build-system gnu-build-system)
    (inputs
     `(("perl" ,perl)))
    (native-inputs
     `(("perl-test-simple" ,perl-test-simple)
       ("perl-test-output" ,perl-test-output)
       ("perl-capture-tiny" ,perl-capture-tiny)
       ("perl-io-stringy" ,perl-io-stringy)))
    (home-page "https://www.gnu.org/software/stow/")
    (synopsis "Managing installed software packages")
    (description
     "GNU Stow is a symlink manager.  It generates symlinks to directories
of data and makes them appear to be merged into the same directory.  It is
typically used for managing software packages installed from source, by
letting you install them apart in distinct directories and then create
symlinks to the files in a common directory such as /usr/local.")
    (license license:gpl3+)))

(define-public xstow
  (package
    (name "xstow")
    (version "1.0.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://sourceforge/xstow/xstow-"
                                  version ".tar.bz2"))
              (sha256
               (base32
                "1vy6lcswpkixh7h5mvsmq2wbcih6lpsmcva3m7v6f5npllciy13g"))))
    (build-system gnu-build-system)
    (synopsis "Replacement of GNU Stow written in C++")
    (description
     "XStow is a replacement of GNU Stow written in C++.  It supports all
features of Stow with some extensions.")
    (home-page "http://xstow.sourceforge.net/")
    (license license:gpl2)))

(define-public rpm
  (package
    (name "rpm")
    (version "4.16.1.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://ftp.rpm.org/releases/rpm-"
                                  (version-major+minor version) ".x/rpm-"
                                  version ".tar.bz2"))
              (sha256
               (base32
                "07g2g0adgjm29wqy94iqhpp5dk0hacfw1yf7kzycrrxnfbwwfgai"))))
    (build-system gnu-build-system)
    (arguments
     '(#:configure-flags '("--with-external-db"   ;use the system's bdb
                           "--enable-python"
                           "--without-lua")
       #:phases (modify-phases %standard-phases
                  (add-before 'configure 'set-nss-library-path
                    (lambda* (#:key inputs #:allow-other-keys)
                      (let ((nss (assoc-ref inputs "nss")))
                        (setenv "LIBRARY_PATH"
                                (string-append (getenv "LIBRARY_PATH") ":"
                                               nss "/lib/nss"))
                        #t))))))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("python" ,python)
       ("xz" ,xz)
       ("bdb" ,bdb)
       ("popt" ,popt)
       ("nss" ,nss)
       ("nspr" ,nspr)
       ("libarchive" ,libarchive)
       ("libgcrypt" ,libgcrypt)
       ("file" ,file)
       ("bzip2" ,bzip2)
       ("zlib" ,zlib)
       ("cpio" ,cpio)))
    (home-page "https://rpm.org/")
    (synopsis "The RPM Package Manager")
    (description
     "The RPM Package Manager (RPM) is a command-line driven package
management system capable of installing, uninstalling, verifying, querying,
and updating computer software packages.  Each software package consists of an
archive of files along with information about the package like its version, a
description.  There is also a library permitting developers to manage such
transactions from C or Python.")

    ;; The whole is GPLv2+; librpm itself is dual-licensed LGPLv2+ | GPLv2+.
    (license license:gpl2+)))

(define-public python-anaconda-client
  (package
    (name "python-anaconda-client")
    (version "1.8.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/Anaconda-Platform/anaconda-client")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1vyk0g0gci4z9psisb8h50zi3j1nwfdg1jw3j76cxv0brln0v3fw"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-clyent" ,python-clyent)
       ("python-nbformat" ,python-nbformat)
       ("python-pyyaml" ,python-pyyaml)
       ("python-requests" ,python-requests)))
    (native-inputs
     `(("python-coverage" ,python-coverage)
       ("python-dateutil" ,python-dateutil)
       ("python-freezegun" ,python-freezegun)
       ("python-mock" ,python-mock)
       ("python-pillow" ,python-pillow)
       ("python-pytz" ,python-pytz)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; This is needed for some tests.
         (add-before 'check 'set-up-home
           (lambda* _ (setenv "HOME" "/tmp") #t))
         (add-before 'check 'remove-network-tests
           (lambda* _
             ;; Remove tests requiring a network connection
             (let ((network-tests '("tests/test_upload.py"
                                    "tests/test_authorizations.py"
                                    "tests/test_login.py"
                                    "tests/test_whoami.py"
                                    "utils/notebook/tests/test_data_uri.py"
                                    "utils/notebook/tests/test_base.py"
                                    "utils/notebook/tests/test_downloader.py"
                                    "inspect_package/tests/test_conda.py")))
               (with-directory-excursion "binstar_client"
                 (for-each delete-file network-tests)))
             #t)))))
    (home-page "https://github.com/Anaconda-Platform/anaconda-client")
    (synopsis "Anaconda Cloud command line client library")
    (description
     "Anaconda Cloud command line client library provides an interface to
Anaconda Cloud.  Anaconda Cloud is useful for sharing packages, notebooks and
environments.")
    (license license:bsd-3)))

(define-public python-conda-package-handling
  (package
    (name "python-conda-package-handling")
    (version "1.7.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/conda/conda-package-handling/")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1dq6f5ks3cinb355x712bls9bvv6bli6x3c43sdkqvawdw8xgv9j"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'use-unmodified-libarchive
           (lambda _
             (substitute* "setup.py"
               (("archive_and_deps") "archive"))))
         (replace 'check
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (add-installed-pythonpath inputs outputs)
             (invoke "pytest" "-vv" "tests"))))))
    (propagated-inputs
     `(("python-six" ,python-six)
       ("python-tqdm" ,python-tqdm)))
    (inputs
     `(("libarchive" ,libarchive)))
    (native-inputs
     `(("python-cython" ,python-cython)
       ("python-pytest" ,python-pytest)
       ("python-pytest-cov" ,python-pytest-cov)
       ("python-pytest-mock" ,python-pytest-mock)
       ("python-mock" ,python-mock)))
    (home-page "https://conda.io")
    (synopsis "Create and extract conda packages of various formats")
    (description
     "This library is an abstraction of Conda package handling and a tool for
extracting, creating, and converting between formats.")
    (license license:bsd-3)))

(define-public conda
  (package
    (name "conda")
    (version "4.10.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/conda/conda")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1w4yy62bsvkybjvcm5fspck4ns5j16nplzpbx6bxv7zhx69pcp4n"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-permissions
           (lambda _
             ;; This file is no longer writable after downloading with
             ;; 'git-fetch'
             (make-file-writable
              "tests/conda_env/support/saved-env/environment.yml")))
         (add-after 'unpack 'fix-ruamel-yaml-dependency
           (lambda _
             (substitute* "setup.py"
               (("ruamel_yaml_conda") "ruamel.yaml"))))
         (add-after 'unpack 'correct-python-executable-name
           (lambda* (#:key inputs #:allow-other-keys)
             (let ((python (assoc-ref inputs "python-wrapper")))
               #;
               (substitute* "conda/common/path.py"
                 (("python_version or ''")
                  "python_version or '3'"))
               (substitute* "conda/core/initialize.py"
                 (("python_exe = join")
                  (format #f "python_exe = \"~a/bin/python\" #"
                          python))))
             #t))
         (add-after 'unpack 'do-not-use-python-root-as-prefix
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out"))
                   (python (assoc-ref inputs "python-wrapper")))
               (substitute* "tests/core/test_initialize.py"
                 (("\"\"\"\\) % conda_prefix")
                  (format #f "\"\"\") % \"~a\"" python))
                 (("CONDA_PYTHON_EXE \"%s\"' % join\\(conda_prefix")
                  (format #f "CONDA_PYTHON_EXE \"%s\"' % join(\"~a\""
                          python))
                 (("conda_prefix = abspath\\(sys.prefix\\)")
                  (format #f "conda_prefix = abspath(\"~a\")" out)))
               (substitute* "conda/base/context.py"
                 (("os.chdir\\(sys.prefix\\)")
                  (format #f "os.chdir(\"~a\")" out))
                 (("sys.prefix, '.condarc'")
                  (format #f "\"~a\", '.condarc'" out))
                 (("return abspath\\(sys.prefix\\)")
                  (format #f "return abspath(\"~a\")" out))
                 (("os.path.join\\(sys.prefix, bin_dir, exe\\)")
                  (format #f "\"~a/bin/conda\"" out))
                 (("'CONDA_EXE', sys.executable")
                  (format #f "'CONDA_EXE', \"~a/bin/conda\"" out))))
             #t))
         (add-before 'build 'create-version-file
           (lambda _
             (with-output-to-file "conda/.version"
               (lambda () (display ,version)))
             #t))
         (replace 'check
           (lambda _
             (setenv "HOME" "/tmp")
             (invoke "py.test" "-vv"
                     "-k"
                     (string-append
                      "not integration"
                      ;; This one reports a newer version of conda than
                      ;; expected.
                      " and not test_auto_update_conda"
                      ;; This fails because the output directory is not a
                      ;; Conda environment.
                      " and not test_list"
                      ;; This fails because we patched the default root
                      ;; prefix.
                      " and not test_default_target_is_root_prefix"

                      ;; These fail because ...
                      ;; TODO: conda patches its own shebang to
                      ;; $conda-prefix/bin/python, which is obviously wrong.
                      " and not test_run_returns_int"
                      " and not test_run_returns_zero_errorlevel"
                      " and not test_run_returns_nonzero_errorlevel"

                      ;; TODO: I don't understand what this failure means
                      " and not test_PrefixData_return_value_contract"
                      ;; TODO: same here
                      " and not test_install_1"
                      ;; Not sure if this is really wrong.  This fails because
                      ;; /gnu/store/...python-conda-4.8.3/bin/python
                      ;; is not /gnu/store/...python-wrapper-3.8.2/bin/python
                      " and not test_make_entry_point"))))
         (add-after 'install 'init
           ;; This writes a whole bunch of shell initialization files to the
           ;; prefix directory.  Many features of conda can only be used after
           ;; running "conda init".
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (add-installed-pythonpath inputs outputs)
             (setenv "HOME" "/tmp")
             (invoke (string-append (assoc-ref outputs "out")
                                    "/bin/conda")
                     "init"))))))
    (inputs
     `(("python-wrapper" ,python-wrapper)))
    (propagated-inputs
     `(("python-anaconda-client" ,python-anaconda-client)
       ("python-conda-package-handling" ,python-conda-package-handling)
       ("python-cytoolz" ,python-cytoolz)
       ("python-pycosat" ,python-pycosat)
       ("python-pytest" ,python-pytest)
       ("python-pyyaml" ,python-pyyaml)
       ("python-requests" ,python-requests)
       ("python-responses" ,python-responses)
       ("python-ruamel.yaml" ,python-ruamel.yaml)
       ("python-tqdm" ,python-tqdm)
       ;; XXX: This is dragged in by libarchive and is needed at runtime.
       ("zstd" ,zstd)))
    (native-inputs
     `(("python-pytest-timeout" ,python-pytest-timeout)))
    (home-page "https://github.com/conda/conda")
    (synopsis "Cross-platform, OS-agnostic, system-level binary package manager")
    (description
     "Conda is a cross-platform, Python-agnostic binary package manager.  It
is the package manager used by Anaconda installations, but it may be used for
other systems as well.  Conda makes environments first-class citizens, making
it easy to create independent environments even for C libraries.  Conda is
written entirely in Python.")
    (license license:bsd-3)))

(define-public python-conda
  (deprecated-package "python-conda" conda))

(define-public conan
  (package
    (name "conan")
    (version "1.40.2")
    (source
     (origin
       (method git-fetch)               ;no tests in PyPI archive
       (uri (git-reference
             (url "https://github.com/conan-io/conan")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0hp8qs54l4cw043f1kycjwgdr7f388lsyxqcbzfaayr6xg1d3dw0"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'relax-requirements
           (lambda _
             (substitute* "conans/requirements.txt"
               (("node-semver==0.6.1")
                "node-semver>=0.6.1"))))
         (add-after 'unpack 'patch-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (let ((coreutils (assoc-ref inputs "coreutils")))
               ;; It seems that PATH is manipulated, as printenv is not found
               ;; during tests.  Patch in its exact location.
               (substitute* "conan/tools/env/environment.py"
                 (("printenv")
                  (string-append coreutils "/bin/printenv")))
               (substitute* "conans/client/envvars/environment.py"
                 (("#!/usr/bin/env")
                  (string-append "#!" coreutils "/bin/env"))))))
         (add-before 'check 'set-home
           (lambda _
             (setenv "HOME" "/tmp")))
         (replace 'check
           (lambda* (#:key tests? outputs #:allow-other-keys)
             (define system ,(or (%current-target-system)
                                 (%current-system)))
             (when tests?
               (setenv "PATH" (string-append (getenv "PATH") ":"
                                             (assoc-ref outputs "out") "/bin"))
               (invoke "python" "-m" "pytest"
                       "-n" "auto"      ;parallelize tests
                       "-m" "not slow and not tool_svn"
                       ;; Disable problematic tests.
                       "-k"
                       (string-append
                        ;; These tests rely on networking.
                        "not shallow_clone_remote "
                        "and not remote_build "
                        "and not download_retries_errors "
                        "and not ftp "
                        "and not build_local_different_folders "
                        ;; These expect CMake available at fixed versions.
                        "and not custom_cmake "
                        "and not default_cmake "
                        "and not bazel " ;bazel is not packaged
                        ;; Guix sets PKG_CONFIG_PATH itself, which is not
                        ;; expected by the following test.
                        "and not pkg_config_path "
                        "and not compare " ;caused by newer node-semver?
                        ;; Guix is not currently a supported package manager.
                        "and not system_package_tool "
                        ;; These expect GCC 5 to be available.
                        "and not test_reuse "
                        "and not test_install "
                        ;; The installed configure script trips on the /bin/sh
                        ;; shebang.  We'd have to patch it in the Python code.
                        "and not test_autotools "
                        "and not test_use_build_virtualenv "
                        ;; This test is architecture-dependent.
                        "and not test_toolchain_linux "
                        ;; This one fails for unknown reasons (see:
                        ;; https://github.com/conan-io/conan/issues/9671).
                        "and not test_build "
                        (if (not (string-prefix? "x86_64" system))
                            ;; These tests either assume the machine is
                            ;; x86_64, or require a cross-compiler to target
                            ;; it.
                            (string-append
                             "and not cpp_package "
                             "and not exclude_code_analysis "
                             "and not cmakedeps_multi "
                             "and not locally_build_linux "
                             "and not custom_configuration "
                             "and not package_from_system "
                             "and not cross_build_command "
                             "and not test_package "
                             "and not test_deleted_os "
                             "and not test_same ")
                            "")
                        (if (not (or (string-prefix? "x86_64" system)
                                     (string-prefix? "i686" system)))
                            ;; These tests either assume the machine is i686,
                            ;; or require a cross-compiler to target it.
                            (string-append
                             "and not vcvars_raises_when_not_found "
                             "and not conditional_generators "
                             "and not test_folders "
                             "and not settings_as_a_dict_conanfile ")
                            "")))))))))
    (propagated-inputs
     `(("python-bottle" ,python-bottle)
       ("python-colorama" ,python-colorama)
       ("python-dateutil" ,python-dateutil)
       ("python-distro" ,python-distro)
       ("python-fasteners" ,python-fasteners)
       ("python-future" ,python-future)
       ("python-jinja2" ,python-jinja2)
       ("python-node-semver" ,python-node-semver)
       ("python-patch-ng" ,python-patch-ng)
       ("python-pluginbase" ,python-pluginbase)
       ("python-pygments" ,python-pygments)
       ("python-pyjwt" ,python-pyjwt)
       ("python-pyyaml" ,python-pyyaml)
       ("python-requests" ,python-requests)
       ("python-six" ,python-six)
       ("python-tqdm" ,python-tqdm)
       ("python-urllib3" ,python-urllib3)))
    (inputs
     `(("coreutils" ,coreutils)))       ;for printenv
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)
       ("cmake" ,cmake)                 ;requires cmake >= 3.17
       ("git" ,git-minimal)
       ("meson" ,meson-0.55)
       ("ninja",ninja)
       ("pkg-config" ,pkg-config)
       ("python-bottle" ,python-bottle)
       ("python-mock" ,python-mock)
       ("python-parameterized" ,python-parameterized)
       ("python-pytest" ,python-pytest)
       ("python-pytest-xdist" ,python-pytest-xdist)
       ("python-webtest" ,python-webtest)
       ("which" ,which)))
    (home-page "https://conan.io")
    (synopsis "Decentralized C/C++ package manager")
    (description "Conan is a package manager for C and C++ developers that
boasts the following features:
@itemize
@item
It is fully decentralized.  Users can host their packages on their own private
servers.
@item
It can create, upload and download binaries for any configuration and
platform, including cross-compiled ones.
@item
It integrates with any build system, including CMake, Makefiles, Meson, etc.
@item
It is extensible; its Python-based recipes, together with extensions points
allow for great power and flexibility.
@end itemize")
    (license license:expat)))

(define-public gwl
  (package
    (name "gwl")
    (version "0.3.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnu/gwl/gwl-" version ".tar.gz"))
              (sha256
               (base32
                "1lqif00mq7fsaknbc2gvvcv1j89k311sm44jp9jklbrv0v2lc83n"))))
    (build-system gnu-build-system)
    (arguments
     `(#:parallel-build? #false ; for reproducibility
       #:make-flags
       '("GUILE_AUTO_COMPILE=0")))
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)
       ("pkg-config" ,pkg-config)
       ("texinfo" ,texinfo)
       ("graphviz" ,graphviz)))
    (inputs
     (let ((p (package-input-rewriting
               `((,guile-3.0 . ,guile-3.0-latest))
               #:deep? #false)))
       `(("guix" ,guix)
         ("guile" ,guile-3.0-latest)
         ("guile-commonmark" ,(p guile-commonmark))
         ("guile-config" ,(p guile-config))
         ("guile-gcrypt" ,(p guile-gcrypt))
         ("guile-pfds" ,(p guile-pfds))
         ("guile-syntax-highlight" ,(p guile-syntax-highlight))
         ("guile-wisp" ,(p guile-wisp)))))
    (home-page "https://workflows.guix.info")
    (synopsis "Workflow management extension for GNU Guix")
    (description "The @dfn{Guix Workflow Language} (GWL) provides an
extension to GNU Guix's declarative language for package management to
automate the execution of programs in scientific workflows.  The GWL
can use process engines to integrate with various computing
environments.")
    ;; The Scheme modules in guix/ and gnu/ are licensed GPL3+,
    ;; the web interface modules in gwl/ are licensed AGPL3+,
    ;; and the fonts included in this package are licensed OFL1.1.
    (license (list license:gpl3+ license:agpl3+ license:silofl1.1))))

(define-public guix-build-coordinator
  (let ((commit "a4d0ec6bc564bbe98d3e6c03be41de16edbda928")
        (revision "35"))
    (package
      (name "guix-build-coordinator")
      (version (git-version "0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://git.cbaines.net/git/guix/build-coordinator")
                      (commit commit)))
                (sha256
                 (base32
                  "0qa7qkskp9xzhyl0fgbm98f8apy8cn2yc9gpxhw0dfc9bkbs1pb9"))
                (file-name (string-append name "-" version "-checkout"))))
      (build-system gnu-build-system)
      (arguments
       `(#:modules (((guix build guile-build-system)
                     #:select (target-guile-effective-version))
                    ,@%gnu-build-system-modules)
         #:imported-modules ((guix build guile-build-system)
                             ,@%gnu-build-system-modules)
         #:phases
         (modify-phases %standard-phases
           (add-before 'build 'set-GUILE_AUTO_COMPILE
             (lambda _
               ;; To avoid warnings relating to 'guild'.
               (setenv "GUILE_AUTO_COMPILE" "0")
               #t))
           (add-after 'install 'wrap-executable
             (lambda* (#:key inputs outputs target #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out"))
                      (bin (string-append out "/bin"))
                      (guile (assoc-ref inputs "guile"))
                      (version (target-guile-effective-version))
                      (scm (string-append out "/share/guile/site/" version))
                      (go  (string-append out "/lib/guile/" version "/site-ccache")))
                 (for-each
                  (lambda (file)
                    (simple-format (current-error-port) "wrapping: ~A\n" file)
                    (let ((guile-inputs (list
                                         "guile-json"
                                         "guile-gcrypt"
                                         "guix"
                                         "guile-prometheus"
                                         "guile-lib"
                                         "guile-lzlib"
                                         "guile-zlib"
                                         "guile-sqlite3"
                                         "gnutls"
                                         ,@(if (hurd-target?)
                                               '()
                                               '("guile-fibers")))))
                      (wrap-program file
                        `("PATH" ":" prefix
                          (,bin
                           ;; Support building without sqitch as an input, as it
                           ;; can't be cross-compiled yet
                           ,@(or (and=> (assoc-ref inputs "sqitch")
                                        list)
                                 '())))
                        `("GUILE_LOAD_PATH" ":" prefix
                          (,scm ,(string-join
                                  (map (lambda (input)
                                         (simple-format
                                          #f "~A/share/guile/site/~A"
                                          (assoc-ref inputs input)
                                          version))
                                       guile-inputs)
                                  ":")))
                        `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                          (,go ,(string-join
                                 (map (lambda (input)
                                        (simple-format
                                         #f "~A/lib/guile/~A/site-ccache"
                                         (assoc-ref inputs input)
                                         version))
                                      guile-inputs)
                                 ":"))))
                      (when target
                        ;; XXX work around wrap-program picking bash for the
                        ;; host rather than target
                        (let ((bash (assoc-ref inputs "bash")))
                          (substitute* file
                            (("^#!.*/bash")
                             (string-append "#! " bash "/bin/bash")))))))
                  (find-files bin)))
               #t))
           (delete 'strip))))             ; As the .go files aren't compatible
      (native-inputs
       `(("pkg-config" ,pkg-config)
         ("autoconf" ,autoconf)
         ("automake" ,automake)
         ("gnutls" ,gnutls)

         ;; Guile libraries are needed here for cross-compilation.
         ("guile-json" ,guile-json-4)
         ("guile-gcrypt" ,guile-gcrypt)
         ("guix" ,guix)
         ("guile-prometheus" ,guile-prometheus)
         ("guile-fibers" ,guile-fibers)
         ("guile-lib" ,guile-lib)
         ("guile" ,@(assoc-ref (package-native-inputs guix) "guile"))))
      (inputs
       `(("guile" ,@(assoc-ref (package-native-inputs guix) "guile"))
         ,@(if (%current-target-system)
               `(("bash" ,bash-minimal))
               '())
         ("sqlite" ,sqlite)
         ,@(if (hurd-target?)
               '()
               `(("sqitch" ,sqitch)))))
      (propagated-inputs
       `(,@(if (hurd-target?)
               '()
               `(("guile-fibers" ,guile-fibers)))
         ("guile-prometheus" ,guile-prometheus)
         ("guile-gcrypt" ,guile-gcrypt)
         ("guile-json" ,guile-json-4)
         ("guile-lib" ,guile-lib)
         ("guile-lzlib" ,guile-lzlib)
         ("guile-zlib" ,guile-zlib)
         ("guile-sqlite3" ,guile-sqlite3)
         ("guix" ,guix)
         ("gnutls" ,gnutls)))
      (home-page "https://git.cbaines.net/guix/build-coordinator/")
      (synopsis "Tool to help build derivations")
      (description
       "The Guix Build Coordinator helps with performing lots of builds across
potentially many machines, and with doing something with the results and
outputs of those builds.")
      (license license:gpl3+))))

(define-public guix-jupyter
  (package
    (name "guix-jupyter")
    (version "0.2.2")
    (home-page "https://gitlab.inria.fr/guix-hpc/guix-kernel")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url home-page)
                                  (commit (string-append "v" version))))
              (sha256
               (base32
                "17m6970wnvwlbarq4gxz5bakhzyhq5ch8qd8jw55ydccpv6473kq"))
              (file-name (string-append "guix-jupyter-" version "-checkout"))))
    (build-system gnu-build-system)
    (arguments
     `(#:modules ((srfi srfi-26)
                  (ice-9 match)
                  (ice-9 popen)
                  (ice-9 rdelim)
                  (guix build utils)
                  (guix build gnu-build-system))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'sed-kernel-json
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out   (assoc-ref outputs "out"))
                    (guix  (assoc-ref inputs  "guix"))
                    (guile (assoc-ref inputs  "guile"))
                    (json  (assoc-ref inputs  "guile-json"))
                    (git   (assoc-ref inputs  "guile-git"))
                    (bs    (assoc-ref inputs  "guile-bytestructures"))
                    (s-zmq (assoc-ref inputs  "guile-simple-zmq"))
                    (gcrypt (assoc-ref inputs  "guile-gcrypt"))
                    (deps  (list out s-zmq guix json git bs gcrypt))
                    (effective
                     (read-line
                      (open-pipe* OPEN_READ
                                  (string-append guile "/bin/guile")
                                  "-c" "(display (effective-version))")))
                    (path (map (cut string-append "-L\", \"" <>
                                    "/share/guile/site/"
                                    effective)
                               deps))
                    (gopath (map (cut string-append "-C\", \"" <>
                                      "/lib/guile/" effective
                                      "/site-ccache")
                                 deps))
                    (kernel-dir (string-append out "/share/jupyter/kernels/guix/")))
               (substitute* (string-append kernel-dir "kernel.json")
                 (("-s")
                  (string-join
                   (list (string-join path "\",\n\t\t\"")
                         (string-join gopath "\",\n\t\t\"")
                         "-s")
                   "\",\n\t\t\""))
                 (("guix-jupyter-kernel.scm")
                  (string-append out "/share/guile/site/3.0/"
                                 "guix-jupyter-kernel.scm")))
               #t))))))
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)
       ("pkg-config" ,pkg-config)

       ;; For testing.
       ("jupyter" ,jupyter)
       ("python-ipython" ,python-ipython)
       ("python-ipykernel" ,python-ipykernel)))
    (inputs
     `(("guix" ,guix)
       ("guile" ,@(assoc-ref (package-native-inputs guix) "guile"))))
    (propagated-inputs
     `(("guile-json" ,guile-json-4)
       ("guile-simple-zmq" ,guile-simple-zmq)
       ("guile-gcrypt" ,guile-gcrypt)))
    (synopsis "Guix kernel for Jupyter")
    (description
     "Guix-Jupyter is a Jupyter kernel.  It allows you to annotate notebooks
with information about their software dependencies, such that code is executed
in the right software environment.  Guix-Jupyter spawns the actual kernels
such as @code{python-ipykernel} on behalf of the notebook user and runs them
in an isolated environment, in separate namespaces.")
    (license license:gpl3+)))

(define-public gcab
  (package
    (name "gcab")
    (version "1.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnome/sources/gcab/"
                                  version "/gcab-" version ".tar.xz"))
              (sha256
               (base32
                "13q43iqld4l50yra45lhvkd376pn6qpk7rkx374zn8y9wsdzm9b7"))))
    (build-system meson-build-system)
    (native-inputs
     `(("glib:bin" ,glib "bin")         ; for glib-mkenums
       ("intltool" ,intltool)
       ("pkg-config" ,pkg-config)
       ("vala" ,vala)))
    (inputs
     `(("glib" ,glib)
       ("zlib" ,zlib)))
    (arguments
     `(#:configure-flags
       ;; XXX This ‘documentation’ is for developers, and fails informatively:
       ;; Error in gtkdoc helper script: 'gtkdoc-mkhtml' failed with status 5
       (list "-Ddocs=false"
             "-Dintrospection=false")))
    (home-page "https://wiki.gnome.org/msitools") ; no dedicated home page
    (synopsis "Microsoft Cabinet file manipulation library")
    (description
     "The libgcab library provides GObject functions to read, write, and modify
Microsoft cabinet (.@dfn{CAB}) files.")
    (license (list license:gpl2+        ; tests/testsuite.at
                   license:lgpl2.1+)))) ; the rest

(define-public msitools
  (package
    (name "msitools")
    (version "0.100")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnome/sources/msitools/"
                                  version "/msitools-" version ".tar.xz"))
              (sha256
               (base32
                "1skq17qr2ic4qr3779j49byfm8rncwbsq9rj1a33ncn2m7isdwdv"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("bison" ,bison)
       ("pkg-config" ,pkg-config)))
    (inputs
     `(("gcab" ,gcab)
       ("glib" ,glib)
       ("libgsf" ,libgsf)
       ("libxml2" ,libxml2)
       ("uuid" ,util-linux "lib")))
    (home-page "https://wiki.gnome.org/msitools")
    (synopsis "Windows Installer file manipulation tool")
    (description
     "msitools is a collection of command-line tools to inspect, extract, build,
and sign Windows@tie{}Installer (.@dfn{MSI}) files.  It aims to be a solution
for packaging and deployment of cross-compiled Windows applications.")
    (license license:lgpl2.1+)))

(define-public libostree
  (package
    (name "libostree")
    (version "2021.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ostreedev/ostree/releases/download/v"
             (version-major+minor version) "/libostree-" version ".tar.xz"))
       (sha256
        (base32 "1cyhr3s7xsgnsais5m4cjwdwcq46naf25r1k042c4n1y1jgs798g"))))
    (build-system gnu-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-before 'check 'pre-check
           (lambda _
             ;; Don't try to use the non-existing '/var/tmp' as test
             ;; directory.
             (setenv "TEST_TMPDIR" (getenv "TMPDIR"))
             #t)))
       ;; XXX: fails with:
       ;;     tap-driver.sh: missing test plan
       ;;     tap-driver.sh: internal error getting exit status
       ;;     tap-driver.sh: fatal: I/O or internal error
       #:tests? #f))
    (native-inputs
     `(("attr" ,attr)                   ; for tests
       ("bison" ,bison)
       ("glib:bin" ,glib "bin")         ; for 'glib-mkenums'
       ("gobject-introspection" ,gobject-introspection)
       ("pkg-config" ,pkg-config)
       ("xsltproc" ,libxslt)))
    (inputs
     `(("avahi" ,avahi)
       ("docbook-xml" ,docbook-xml-4.2)
       ("docbook-xsl" ,docbook-xsl)
       ("e2fsprogs" ,e2fsprogs)
       ("fuse" ,fuse)
       ("glib" ,glib)
       ("gpgme" ,gpgme)
       ("libarchive" ,libarchive)
       ("libsoup" ,libsoup)
       ("util-linux" ,util-linux)))
    (home-page "https://ostree.readthedocs.io/en/latest/")
    (synopsis "Operating system and container binary deployment and upgrades")
    (description
     "@code{libostree} is both a shared library and suite of command line
tools that combines a \"git-like\" model for committing and downloading
bootable file system trees, along with a layer for deploying them and managing
the boot loader configuration.")
    (license license:lgpl2.0+)))

(define-public flatpak
  (package
   (name "flatpak")
   (version "1.10.2")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://github.com/flatpak/flatpak/releases/download/"
                         version "/flatpak-" version ".tar.xz"))
     (sha256
      (base32 "1r6xw7r3ir2vaa30n3mily6m7d51cf4qv22fkqlzzy3js0wjf5fv"))))

   ;; Wrap 'flatpak' so that GIO_EXTRA_MODULES is set, thereby allowing GIO to
   ;; find the TLS backend in glib-networking.
   (build-system glib-or-gtk-build-system)

   (arguments
    '(#:configure-flags
      (list
       "--enable-documentation=no" ;; FIXME
       "--enable-system-helper=no"
       "--localstatedir=/var"
       (string-append "--with-system-bubblewrap="
                      (assoc-ref %build-inputs "bubblewrap")
                      "/bin/bwrap")
       (string-append "--with-system-dbus-proxy="
                      (assoc-ref %build-inputs "xdg-dbus-proxy")
                      "/bin/xdg-dbus-proxy"))
      #:phases
      (modify-phases %standard-phases
        (add-after 'unpack 'fix-tests
          (lambda* (#:key inputs #:allow-other-keys)
            (copy-recursively
             (string-append (assoc-ref inputs "glibc-utf8-locales")
                            "/lib/locale/") "/tmp/locale")
            (for-each make-file-writable (find-files "/tmp"))
            (substitute* "tests/make-test-runtime.sh"
              (("cp `which.*") "echo guix\n")
              (("cp -r /usr/lib/locale/C\\.\\*")
               (string-append "mkdir ${DIR}/usr/lib/locale/en_US; \
cp -r /tmp/locale/*/en_US.*")))
            (substitute* "tests/libtest.sh"
              (("/bin/kill") (which "kill"))
              (("/usr/bin/python3") (which "python3")))
            #t))
        ;; Many tests fail for unknown reasons, so we just run a few basic
        ;; tests.
        (replace 'check
          (lambda _
            (setenv "HOME" "/tmp")
            (invoke "make" "check"
                    "TESTS=tests/test-basic.sh tests/test-config.sh testcommon"))))))
    (native-inputs
    `(("bison" ,bison)
      ("dbus" ,dbus) ; for dbus-daemon
      ("gettext" ,gettext-minimal)
      ("glib:bin" ,glib "bin")          ; for glib-mkenums + gdbus-codegen
      ("glibc-utf8-locales" ,glibc-utf8-locales)
      ("gobject-introspection" ,gobject-introspection)
      ("libcap" ,libcap)
      ("pkg-config" ,pkg-config)
      ("python" ,python)
      ("python-pyparsing" ,python-pyparsing)
      ("socat" ,socat)
      ("which" ,which)))
   (propagated-inputs `(("glib-networking" ,glib-networking)
                        ("gnupg" ,gnupg)
                        ("gsettings-desktop-schemas"
                         ,gsettings-desktop-schemas)))
   (inputs
    `(("appstream-glib" ,appstream-glib)
      ("bubblewrap" ,bubblewrap)
      ("dconf" ,dconf)
      ("fuse" ,fuse)
      ("gdk-pixbuf" ,gdk-pixbuf)
      ("gpgme" ,gpgme)
      ("json-glib" ,json-glib)
      ("libarchive" ,libarchive)
      ("libostree" ,libostree)
      ("libseccomp" ,libseccomp)
      ("libsoup" ,libsoup)
      ("libxau" ,libxau)
      ("libxml2" ,libxml2)
      ("util-linux" ,util-linux)
      ("xdg-dbus-proxy" ,xdg-dbus-proxy)))
   (home-page "https://flatpak.org")
   (synopsis "System for building, distributing, and running sandboxed desktop
applications")
   (description "Flatpak is a system for building, distributing, and running
sandboxed desktop applications on GNU/Linux.")
   (license license:lgpl2.1+)))

(define-public akku
  (package
    (name "akku")
    (version "1.0.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.com/akkuscm/akku.git")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256 (base32 "1dm32ws3nshnnscd7k75zswxxs1pp25y2q4k8j5ms241hz47by3c"))))
    (build-system gnu-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                  (replace 'bootstrap
                    (lambda* (#:key outputs #:allow-other-keys)
                      (for-each patch-shebang
                                '("bootstrap"
                                  ".akku/env"))
                      (let* ((home "/tmp")
                             (datadir (string-append home "/.local/share/akku/")))
                        (mkdir-p datadir)
                        (invoke "touch" (string-append datadir "index.db"))
                        (setenv "HOME" home))
                      (invoke "./bootstrap")
                      #t))
                  (add-after 'install 'wrap-executables
                    (lambda* (#:key outputs inputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out"))
                            (curl (assoc-ref inputs "curl")))
                        (wrap-program (string-append out "/bin/akku")
                          `("LD_LIBRARY_PATH" ":" prefix (,(string-append curl "/lib"))))
                        #t))))))
    (native-inputs
     `(("which" ,which)
       ("autoconf" ,autoconf)
       ("automake" ,automake)
       ("pkg-config" ,pkg-config)))
    (inputs
     `(("guile" ,guile-3.0)
       ("curl" ,curl)))
    (home-page "https://akkuscm.org/")
    (synopsis "Language package manager for Scheme")
    (description
     "Akku.scm is a project-based language package manager for R6RS and R7RS Scheme.
It is mainly meant for programmers who develop portable programs or libraries in Scheme,
but could potentially work for end-users of those programs.  It also has a translator
from R7RS, which allows most R7RS code to run on R6RS implementations.")
    (license license:gpl3+)))

(define-public modules
  (package
    (name "modules")
    (version "4.8.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "mirror://sourceforge/modules/Modules/modules-"
                            version "/modules-" version ".tar.bz2"))
        (sha256 (base32 "1amz8qdqbvfdc8jv0j4720vywbz2gi7l3sr1lh37ilfbxy9lq9g9"))))
    (build-system gnu-build-system)
    (arguments
      `(#:configure-flags
        (list (string-append "--with-bin-search-path="
                             (assoc-ref %build-inputs "tcl") "/bin" ":"
                             (assoc-ref %build-inputs "procps") "/bin" ":"
                             (assoc-ref %build-inputs "less") "/bin" ":"
                             (assoc-ref %build-inputs "coreutils") "/bin")
              (string-append "--with-tcl=" (assoc-ref %build-inputs "tcl") "/lib")
              "--disable-compat-version")
        #:test-target "test"
        #:phases
        (modify-phases %standard-phases
          (add-before 'configure 'patch-add-modules
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((coreutils (assoc-ref inputs "coreutils")))
                (substitute* "script/add.modules.in"
                  (("/bin/(cat|cp|rm)" _ command)
                   (string-append coreutils "/bin/" command))
                  (("/bin/echo")
                   "echo")))))
          (add-before 'configure 'patch-scripts-for-python-3
            (lambda _
              ;; Patch the script for python-3.
              (substitute* "script/createmodule.py.in"
                (("pathkeys.sort\\(\\)") "pathkeys = sorted(pathkeys)")
                (("print\\(\"\\\\t\"\\*") "print(\"\\t\"*int")
                (("@PYTHON@") (which "python3")))))
          (add-before 'check 'patch-/bin/sh-and-nixbld-groups-in-tests
            (lambda _
              (use-modules (srfi srfi-1))
              (let* ((groups-file (string-append (getcwd) "/nixbld-groups"))
                     (groups-file-z (string-append groups-file "-z"))
                     (nixbld-groups
                       (fold
                         (lambda (id prev)
                           (catch #t
                             (lambda () (cons (group:name (getgrnam id)) prev))
                             (lambda _ prev)))
                         '()
                         (vector->list (getgroups)))))
                ;; Simulate "id -G -n" command output.
                (call-with-output-file groups-file
                  (lambda (port)
                    (display (string-join nixbld-groups " ") port)
                    (display #\newline port)))
                ;; Simulate "id -G -n -z" command output.
                (call-with-output-file groups-file-z
                  (lambda (port)
                    (for-each
                      (lambda (group-name)
                        (display group-name port)
                        (display #\null port))
                      nixbld-groups)))
                ;; Generate "modulecmd-test.tcl" before running "make test".
                (invoke "make" "modulecmd-test.tcl")
                ;; Substitute shell.
                (substitute*
                  '("modulecmd-test.tcl"
                    "modulecmd.tcl"
                    "testsuite/modules.70-maint/380-edit.exp"
                    "compat/init/filter")
                  (("/bin/sh") (which "sh")))
                ;; Skip tests that use supplementary groups.
                (for-each
                  delete-file
                  '("testsuite/modules.20-locate/112-hide-user-group.exp"
                    "testsuite/modules.20-locate/117-forbid-user-group.exp"
                    "testsuite/modules.20-locate/119-hide-cascading.exp"
                    "testsuite/modules.50-cmds/140-system.exp"
                    "testsuite/modules.50-cmds/287-info-usergroups.exp"
                    "testsuite/modules.50-cmds/440-module-tag.exp"
                    "testsuite/modules.70-maint/220-config.exp"))
                (for-each
                  (lambda (file)
                    (substitute* file
                      (("/bin/sh") (which "bash"))
                      ;; For some reason "kvm" group cannot be resolved for
                      ;; "nixbld" user. We replace "id ..." commands with
                      ;; "cat ..." that simulates them.
                      (("exec id -G -n -z") (string-append "exec cat " groups-file-z))
                      (("exec id -G -n") (string-append "exec cat " groups-file))))
                  '("testsuite/modules.00-init/005-init_ts.exp"
                    "testsuite/install.00-init/005-init_ts.exp"
                    "modulecmd-test.tcl"))))))))
    (native-inputs
      `(("dejagnu" ,dejagnu)
        ("autoconf" ,autoconf)
        ("which" ,which)))
    (inputs
      `(("tcl" ,tcl)
        ("less" ,less)
        ("procps" ,procps)
        ("coreutils" ,coreutils)
        ("python" ,python-3)))
    (home-page "http://modules.sourceforge.net/")
    (synopsis "Shell environment variables and aliases management")
    (description "Modules simplify shell initialization and let users
modify their environment during the session with modulefiles.  Modules are
used on high-performance clusters to dynamically add and remove paths
to specific versions of applications.")
    (license license:gpl2+)))
