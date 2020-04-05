# Dog Breeds

Fetches info about given dog breeds from [Dog API](https://dog.ceo/dog-api/).

## Usage

`>ruby breeds.rb bulldog-boston chihuahua cattledog`

### Sub-breeds

Some dog breeds have sub-breed, like `boston bulldog`. The sub-breed may or may not be specified. 
If specified, data for the sub-breed are fetched. If not, data for ALL sub-breeds are fetched.

Sub-breeds are specified as a dash-separated suffix to the breed, like `bulldog-boston`.

## Description

Fetches links to photos of given dog breeds, each in a separate thread (TODO or fibre?).
 Downloaded data are stored in the `out` directory together. There are two kinds of files:

### CSV files

Each breed info is stored into `{breed_name}.csv`: eg. `bulldog-boston.csv` if sub-breed was given or `bulldog.csv` 
if not. CSV files contain columns `breed name` and `link to the image`.

### JSON file

Single JSON file `updated_at.json` contains a list of all the downloaded files and timestamp of when each of them was 
created.
  
## Logging

Logs to stdout.

## Troubleshooting

Section for Ops observing issues with the script. 

### Script is irresponsive, misbehaving etc

Kill the script, no need to restart it. Please inform the owner at my@email.com and send the log.

### Running out of disk space

All output is stored in `out` directory. The script only downloads links to the images, NOT the images themselves, 
so the data shouldn't consume any considerable amount of disk space. If that's the case though, feel free delete 
all the files. 

## Questions, ToDos

  * download just the links, or also the images themselves?
  * how to handle sub-breeds - must the sub-breed be specified?
  * who will be calling the script - human / machine?
    * implies error handling (fail / log error and carry on)
    * I would sub-breeds be specified differently (`boston bulldog` instead of `bulldog-boston`) 
    * I might add similarity search for human (using eg. Levenshtein distance), though it would be a nicer fit to add it 
    to the API 
  * logging - file / stdout
  * file overwriting
  * file creation date - shouldn't have taken the file attribute?
  * it would be sexier to have sub-breed in CSV even if only master breed was specified
  * RuboCop exceptions
  * document param formats