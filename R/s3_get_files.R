s3_get_files <- function(s3_uri,
                         download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads")),
                         quiet = TRUE,
                         force = FALSE,
                         confirm = TRUE) {

    # TODO: add in checking for each file up front, so we can report an accurate total download size only actually for the files that will be downloaded

    n_files <- length(s3_uri)

    files_size <-
        purrr::map(s3_uri, s3_file_size) %>%
        purrr::reduce(`+`)

    cli::cli_alert_info("{n_files} file{?s} totaling {prettyunits::pretty_bytes(files_size)} will be downloaded to {download_folder} ")
    if (confirm) ui_confirm()

    f <- function() {
        cli::cli_alert_info("Now downloading {n_files} file{?s}, {prettyunits::pretty_bytes(files_size)} in total size")
        sb <- cli::cli_status("{cli::symbol$arrow_right} Downloading {n_files} files.")

        for (i in n_files:1) {
            s3_get(s3_uri[i], quiet = quiet, force = force)
            cli::cli_status_update(
                id = sb,
                "{cli::symbol$arrow_right} Got {n_files - i} file{?s}, downloading {i}"
            )
        }
        cli::cli_status_clear(id = sb)
    }


    download_time <- system.time(f())["elapsed"]

    cli::cli_alert_success("Downloaded {n_files} file{?s} in {prettyunits::pretty_sec(download_time)}.")

    return(invisible(NULL))
}