# arctools 1.1.0

* Added a `NEWS.md` file to track changes to the package.
* Added a protective step in `midnight_to_midnight` to protect from errors coming from providing a function with `base::as.POSIXct()`-generated timestamp (not ok) instead of `lubridate::ymd_hms()`-generated timestamp. 
