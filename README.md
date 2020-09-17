# Interview Form RDF

LINC Interview Form RDF project

## How to contribute

For the first time:

```sh
% git clone https://github.com/med2rdf/interview-form.git
% cd interview-form
```

Afterwards:

Below is the old way.

```sh
% git pull
(edit benitas/sectionXX.ttl)
% git status
% git diff
% git add benitas/sectionXX.ttl
% git commit
(add comments on edits)
% git push
```

We now simplified the RDF generation process to (1) fill the template on the Google spreadsheet, (2) dump three CSV files from the sheet, and (3) convert the CSV files into RDF/Turtle by a script.

```sh
% bin/if-csv2ttl.rb drugs/drug/meta.csv drugs/drug/if.csv drugs/drug/ref.csv > drug.ttl
```
