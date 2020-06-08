## Test environments
- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results 
> On windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release), fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Federico Garza <fede.garza.ramirez@gmail.com>'
  
  New submission

0 errors ✓ | 0 warnings ✓ | 1 note x

Changes:
- Using single quotes just for packages in description in the DESCRIPTION file. 
- Improving description in the DESCRIPTION file (removing ambiguous explanations).
- Using FALSE instead of F in wald_test function.
