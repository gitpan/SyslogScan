use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "SyslogScan",
	DISTNAME => "SyslogScan",
	VERSION => "0.30",
	EXE_FILES => [ qw( read_mail_log.pl ) ],
	dist => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
);
