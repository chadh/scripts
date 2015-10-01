#!/usr/bin/perl -w

use Cwd;

use strict 'vars';
use strict 'subs';

if ( $#ARGV < 1 ) {
        print "$#ARGV\n";
	print "\tUsage: $0 <feature> <group>\n\n";
	exit 1;
}

my @groups = ("research", "infrastructure", "instruction");
my $repo = 'ssh://git@github.gatech.edu';
my $puppetdir = '/etc/puppet/environments';
#my $lp = '/usr/bin/librarian-puppet';
my $lp = '/usr/bin/r10k puppetfile';

my $feature = $ARGV[0];
my $group = $ARGV[1];
my $org = "tso-$group";
my $envname = $group . "_" . $feature;
my $stdout;

if ( ! grep { $_ eq $group } @groups ) {
	die "Error: Invalid group $group specified.  Must be one of '@groups'";
}

chdir $puppetdir || die "Error: Unable to cd to $puppetdir";
if ( -d $envname ) {
	die "Error: Environment $envname already exists";
}
printf "Cloning $group environment repo...";
$stdout = `git clone $repo/$org/puppet-environment.git $envname 2>&1`;
if ($? != 0 ) {
	die "Failed!";
}
chdir $envname || die "Error: Unable to cd to $envname";

$stdout = `git branch -f $feature 2>&1`;
if ( $? != 0 ) {
#		  printf "$stdout";
  printf "\nWarning: Failed to create $feature branch!\n";
} else {
  $stdout = `git co $feature 2>&1`;
  if ( $? != 0 ) {
#		  printf "$stdout";
    printf "\nWarning: Failed to checkout $feature branch\n";
  }
}

printf "done\n";

printf "Fetching modules...";
$stdout = `$lp install 2>&1`;
if ( $? != 0 ) {
	printf "$stdout";
	die "Failed!";
}
printf "done.\n";

if ( defined $feature ) {
  printf "Checking out the $feature branch...";
  opendir(DIR, "modules");
  my @mods = readdir(DIR);
  closedir(DIR);
  foreach my $mod (@mods) {
	if ( $mod eq ".." ) {
		next;
	}

	my $orig_cwd = cwd;
	chdir("modules/$mod") || die "failed to chdir into modules/$mod";
	if ( -d ".git") {
		my $remote = `git remote -v | awk '{ print \$2; }'`;
		if ( $remote !~ m/.*(gatech).*/i ) {
#			printf "remote: $remote\n";
#			printf "\tskipping module $mod because not ours\n";
			chdir($orig_cwd);
			next;
		}
		$stdout = `git branch -f $feature 2>&1`;
		if ( $? != 0 ) {
#		  printf "$stdout";
                  printf "[!$mod] ";
		}
		$stdout = `git co $feature 2>&1`;
		if ( $? != 0 ) {
#		  printf "$stdout";
                  printf "[!$mod] ";
		}
	}
	chdir($orig_cwd) || die "failed to chdir into $orig_cwd";
  }
  printf "done.\n";
}

printf "Cloning hieradata...";
if ( ! -d "hieradata" ) {
	mkdir("hieradata") || die "failed to make hieradata";
}
chdir("hieradata") || die "failed to chdir into hieradata";
$stdout = `git clone $repo/$org/puppet-hieradata-modules.git modules 2>&1`;
if ( $? != 0 ) {
	die "Failed!";
}

chdir("modules") || die "Error: Unable to cd to $envname/hieradata/modules";
$stdout = `git branch -f $feature 2>&1`;
if ( $? != 0 ) {
#		  printf "$stdout";
  printf "\nWarning: Failed to create $feature branch!\n";
} else {
  $stdout = `git co $feature 2>&1`;
  if ( $? != 0 ) {
#		  printf "$stdout";
    printf "\nWarning: Failed to checkout $feature branch\n";
  }
}

printf "done.\n";

printf "\nFinished creating new puppet environment '$envname'\n";

exit 0;
