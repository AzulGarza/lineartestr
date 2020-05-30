## Test environments
- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results
> On windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release), fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... NOTE
  
  New submission
  Maintainer: 'Federico Garza <fede.garza.ramirez@gmail.com>'

0 errors ✓ | 0 warnings ✓ | 1 note x

Changes:
- Adding () to all function names in the description text in the DESCRIPTION file.
- Explaining acronyms/abbreviations in the description text in the Description field of the DESCRIPTION file.
- Removing some single quotes in description in the DESCRIPTION file. 
- Removing LICENSE file from building.
- Adding compatibility with dplyr 1.0.0 (plot functions).
