# Docker configuration for personal DokuWiki instance

Václav Brožík, 2024

The configuration uses Docker Compose to run a [DokuWiki](https://www.dokuwiki.org/) instance. It uses image with PHP 8 and Apache ([`php:8-apache`](https://hub.docker.com/_/php/tags?name=8-apache)). DokuWiki itself is not part of the compose definition. It is installed in a volume and is part of the backup archive together with the wiki content. DokuWiki can be upgraded using the official Wiki Upgrade plugin.

## Instructions for setting up the DokuWiki instance

1. Create a project directory for the DokuWiki instance. It will normally contain just this file and backup archive files. Docker compose will automatically use the directory name as the project name.
2. Put the backup of the DokuWiki data into the project directory and link[^1] or rename it to:  
    `dokuwiki_data_backup_current.tbz`
3. Run the following command to initialize the data volume:  
    `docker compose run --rm restore`
4. Run the following command to start the DokuWiki instance in the background:  
    `docker compose up -d`
5. The web server will be available at:  
    [`http://localhost:40800/`](http://localhost:40800/)

Use environment variables or edit the `compose.yaml` file to change parameters.

## Instructions for backing up the DokuWiki instance

You can use the script `backup.sh` which will make a backup an also copy it to a remote machine. Instructions for manual backup are below.

1. Run the following commands to stop the DokuWiki instance and create a backup:

    ``` shell
    docker compose stop dokuwiki
    docker compose run --rm backup
    ```

2. The backup will be created in the project directory named
    `dokuwiki_data_backup_YYYYMMDDhhmmss.tbz`. Move it to a safe location.
3. Run the following command to start the DokuWiki instance again:  
    `docker compose up -d`

## TODO

- Initialize DokuWiki from a backup on the first run. Check if a special service with a profile can be used for this initialization.
- Split volume to: `dokuwiki_software`, `dokuwiki_data`, `dokuwiki_config`.
- Use `Dockerfile` to tune the image for DokuWiki and to install the DokuWiki into the image.
    If DokuWiki installation is not added, add at least instructions for clean installation of DokuWiki.
- Use `xz` instead of `bzip2` for better compression. It is not available in the Alpine Linux image.

[^1]: Symlink may not work because during the restore the directory with the file is mounted as `/backup`.
