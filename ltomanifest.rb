#!/usr/bin/env ruby

require 'bagit'
require 'yaml'
require 'optparse'

option = {}

OptionParser.new do |opts|
  opts.banner = "Usage: ltomanifest.rb [option] [inputfile]"

  opts.on("-m", "--make", "Make manifest") do |e|
    option = 'make'
  end
  opts.on("-c", "--confirm", "Confirm manifest") do |d|
    option = 'confirm'
  end
  opts.on("-h", "--help", "Help") do
    puts opts
    exit
  end
  if ARGV.empty?
    puts opts
  end
end.parse!

input=ARGV
TargetBags = Array.new

# Methods for colored text output
def red(input)
  puts "\e[31m#{input}\e[0m"
end

def green(input)
  puts "\e[36m#{input}\e[0m"
end

def Create_manifest(input)
#Check and limit input
  if input.length > 1
    red("Please only use one directory as input. Exiting.")
    exit
  else
    input = input[0]
  end

  if ! File.directory?(input)
    red("Input is not a valid directory. Exiting")
    exit
  elsif File.exist?("#{input}/tapemanifest.txt")
    red("#{input}/tapemanifest.txt already exists. Exiting.")
    exit
  end
  #Get list of directories
  Dir.chdir(input)
  bag_list = Dir.glob('*')
  #Check if supposed bags are actually directories
  bag_list.each do |isdirectory|
    if ! File.directory?(isdirectory)
      red("Warning! Files not contained in bags found at -- #{isdirectory} -- Exiting.")
      exit
    end
  end

  #Check if directories are bags (contains metadata files)
  bag_list.each do |isbag|
    if ! File.exist?("#{isbag}/bag-info.txt") || ! File.exist?("#{isbag}/bagit.txt")
      red("Warning! Unbagged directory found at -- #{isbag} Exiting.")
    end
  end

  #Verify all bags are valid bags
  bag_list.each do |isvalidbag|
    bag = BagIt::Bag.new isvalidbag
    if bag.valid?
      TargetBags << isvalidbag
    else
      red("Warning! Invalid Bag Detected at -- #{isvalidbag} -- Dumping List of Validated Bags and Exiting!")
        data = {"ConfirmedBags" => TargetBags}
        File.write('BagListDump.txt',data.to_yaml)
      exit
    end
  end
  targetBagsSorted = TargetBags.sort
  bagcontents = Array.new
  #Gather checksums from individual bags
  targetBagsSorted.each do |bagparse|
    metafile = "#{bagparse}/manifest-md5.txt"
    contents = File.readlines(metafile)
    bagcontents << bagparse
    bagcontents << contents
  end

  #Write manifest of bags and checksums
  data = {"Bag List" => targetBagsSorted, "Contents" => bagcontents}
  File.write('tapemanifest.txt',data.to_yaml)
  green("Manifest written at #{input}/tapemanifest.txt")
end

def Auditmanifest(input)
  #Confirm input
  if input.length > 1
    red("Please only use one maifest file as input. Exiting.")
    exit  
  else
    input = input[0]
  end
  if ! File.exist?(input)
    red("Please use a valid input file")
    exit
  end
  #Read manifest file
  manifestlocation = File.dirname(input)
  manifestinfo = YAML::load_file(input) || red(error)
  bags = manifestinfo['Bag List']
  Dir.chdir(manifestlocation)
  #Confirm validity of all bags listed in manifest file
  confirmedBags = Array.new
  problemBags = Array.new
  if bags.empty?
    red 'No Bag Information Found. Please Confirm Manifest'
  end
  bags.each do |isvalidbag|
    bag = BagIt::Bag.new isvalidbag
    if bag.valid?
      green("Contents Confirmed: #{isvalidbag}")
      confirmedBags << isvalidbag
    else
      puts "Warning: Invalid bag found at -- #{isvalidbag}"
      problemBags << isvalidbag
    end
  end
  #List warning of problem bags
  if problemBags.length > 0
    red("These Bags Failed Verification")
    red(problemBags)
  else
    green("All Bags Verified Successfully")
  end
end

if option == 'make'
  Create_manifest(input)
elsif option == 'confirm'
  Auditmanifest(input)
else
  puts "You must use an option"
end
