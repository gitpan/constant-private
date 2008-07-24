BEGIN { require 5.008 } # 5.6.[12] %^H scoping bug

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'constant::private',
    AUTHOR              => 'Father Chrysostomos <sprout [hat] cpan . org>',
    VERSION_FROM        => 'lib/constant/private.pm',
    ABSTRACT_FROM       => 'lib/constant/private.pm',
    PL_FILES            => {},
    PREREQ_PM => {
         constant                         => 0,
         Sub::Delete                      => 0,
# for testing:
	Test::More => 0,
    },
    dist               => { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
                            TAR => 'COPYFILE_DISABLE=1 tar' },
    clean              => { FILES => 'constant-private-*' },
);
