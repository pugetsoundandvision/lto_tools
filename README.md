## Make manifest for LTO
LTO TOOLS finds Bags that meet the Library of Congress Bagit specification, copies the manifest for each of them, and compiles these into a single combined manifest.

Needs Ruby bagit gem to be installed. Run `sudo gem install bagit`

To install, run `brew install ltotools`

Creates and verifies tape manifests to be used in conjunction with AMIA Open Source's [LTOpers](https://github.com/amiaopensource/ltopers) scripts. 

For example, you could create a manifest using lto tools, write that manifest (and the accompanying data) to LTO using ltopers, then confirm the contents of the manifest using lto tools.


Usage
`ltomanifest [option] [inputfile]`

Options
[-m] = Make manifest.
[-c] = Confirm manifest.
[-b] = Bag dump.
[-h, --help, Help] = Describes options.
