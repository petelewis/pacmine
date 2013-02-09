require 'hpricot'
require 'open-uri'

# Get a list of packages for the maintainer specified
# If file is a string containing a filename, query that instead, ignoring
# whichever maintainer username was given.
def get_package_list maintainer, file=nil

  # Query the package source
  if file
    begin
      doc = Hpricot( File.open(file, "r") { |f| f.read } )
    rescue
      warn "There was a problem reading the file specified."
      exit 1
    end
  else
    begin
      doc = open("https://www.archlinux.org/packages/?sort=&q=&maintainer=#{maintainer}&limit=9999") { |f| Hpricot(f) }
    rescue
      warn "There was a problem querying www.archlinux.org for the package list."
      exit 1
    end
  end

  # Get the results table from the document
  table = doc.at("//table[@class='results']")

  # Put each of the rows in the table into an array
  begin
    rows = table.search("//tr")
  rescue
    warn "Could not find any packages."
    exit 1
  end

  # Remove the first row, which contains column headers
  rows.shift

  # We will store our list of packages here
  packages = Array.new

  # Collect the packages and their repos from the array of rows,
  # put them in to the packages array.
  rows.each do |row|

    # The columns (td elements) for this row
    columns = row.search("//td")

    # The repo is in column 1
    repo = columns[1].inner_html.downcase

    # The package name is in column 2 as a hyperlink
    pkgname = columns[2].at("//a").inner_html

    # Add this package and repo name to the packages array
    packages.push ({:repo => repo, :pkgname => pkgname})

  end

  # Finally, remove duplicates and return.
  # (For example, packages with multiple architectures will be duplicated).
  packages.uniq

end

# This method takes an array of packages and filters it by repo.
# Another package array is returned, with only those packages in 'repo' present.
def filter_by_repo(packages, repo)

  packages.keep_if { |package| package[:repo] === repo }

end

# This method takes an array of packages and filters it by name.
# Another package array is returned, with only those packages whose name matches
# the regular expression given.
def filter_by_name(packages, regexp)

  packages.keep_if { |package| package[:pkgname].match(regexp) }

end
