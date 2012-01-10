require 'hpricot'
require 'open-uri'
require 'commander/import'

program :version, '0.0.1'
program :description, "A tool to get a list of someone's packages from archlinux.org"

# Default to the intro / help page
default_command :help

command :list do |c|
  c.syntax = 'pacmine list [user]'
  c.description = "List the packages maintained by the specified user. Defaults to 'orphan'."
  c.option '--file <filename>', String, 'Query the specified file instead of archlinux.org.'
  c.action do |args, options|

    # Set the to be the maintainer to pull packages for.
    if args[0]
      maintainer = args[0]
    else
      maintainer = "orphan"
    end

    # If we've been passed a --file <filename>, then query that instead of the
    # archlinux.org server.
    if options.file
      if args[0]
        warn "It doesn't make sense to specify a user when using --file."
        exit 1
      end
      doc = Hpricot( File.open(options.file, "r") { |f| f.read } )
    else
      # Pull package list page from archlinux.org
      begin
        doc = open("http://www.archlinux.org/packages/?sort=&q=&maintainer=#{maintainer}&limit=9999") { |f| Hpricot(f) }
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
      warn "Error: Could not find any packages."
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

    # Finally, remove duplicates.
    # (For example, packages with multiple architectures will be duplicated).
    packages.uniq!

    # And print out the repo and package names
    packages.each { |package| puts "#{package[:repo]} #{package[:pkgname]}" }

  end
end
