= pacmine

* https://rubygems.org/gems/pacmine

== DESCRIPTION:

* pacmine is a small tool to get a list of the packages a person maintains from archlinux.org.

== FEATURES/PROBLEMS:

* Given a maintainer's username, pacmine queries the package database at
* archlinux.org/packages and return a list of the packages that person
* maintains.

== SYNOPSIS:

  pacmine list aaron
  pacmine list orphan
  pacmine list plewis --repo community
  pacmine list orphan --filter "kde"

== REQUIREMENTS:

* commander
* hpricot

== INSTALL:

* If you have rubygems set up: gem install pacmine
* Or from the AUR: https://aur.archlinux.org/packages.php?ID=55713

== LICENSE:

GPL version 3, or at your option, any later version.
