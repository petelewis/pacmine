require 'hpricot'
require 'open-uri'

# Set this to be the maintainer to pull packages for
maintainer = "plewis"

# For testing: use a file instead of pulling from archlinux.org
#doc = Hpricot( File.open("test.html", "r") { |f| f.read } )

# Pull package list page from archlinux.org
begin
  doc = open("http://www.archlinux.org/packages/?sort=&q=&maintainer=#{maintainer}") { |f| Hpricot(f) }
rescue
  puts "There was a problem querying www.archlinux.org for the package list."
  exit
end

# Get the results table from the document
table = doc.at("//table[@class='results']")

# Put each of the rows in the table into an array
rows = table.search("//tr")

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

# Finally, remove duplicates.
# (For example, packages with multiple architectures will be duplicated).
packages.uniq!

# And print out the repo and package names
packages.each { |package| puts "#{package[:repo]} #{package[:pkgname]}" }

