# Paperless-ngx: Production-Ready Docker Compose

This repository provides a **production-ready Docker Compose** setup for deploying [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx), an open-source document management system.

This configuration is designed to be **standalone, secure, and resilient**, including automated backup services for the database and your files.

## ✨ Features

* **Containerized:** All services (Paperless-ngx, PostgreSQL, Redis) are containerized for a simple and isolated deployment.
* **Automated Backups:**
    * **Database:** Automatic daily backups of the PostgreSQL database.
    * **Media:** Automatic daily backups of all your documents.
* **Secure:** Uses an `.env` file to manage credentials and secret keys.
* **Production-Ready:** Configurations are optimized for stability and performance.
* **Comprehensive Documentation:** Includes clear procedures for deployment and disaster recovery.

---

## 🚀 Getting Started

### Prerequisites

* **Docker:** [Install Docker](https://docs.docker.com/get-docker/)
* **Docker Compose:** [Install Docker Compose](https://docs.docker.com/compose/install/)

### 1. Initial Setup

1.  **Clone this repository:**
    ```bash
    git clone <URL_OF_YOUR_REPOSITORY> paperless-ngx
    cd paperless-ngx
    ```

2.  **Create the necessary directories:**
    These volumes will be used to persist Paperless data and backups.
    ```bash
    mkdir -p data media export consume backups
    ```

3.  **Set up environment variables:**
    Copy the example file and modify it with your own values.
    ```bash
    cp .env.example .env
    ```
    Open the `.env` file and set the following variables:
    * `PAPERLESS_ADMIN_USER` and `PAPERLESS_ADMIN_PASSWORD`: The credentials for your first login.
    * **`PAPERLESS_SECRET_KEY`**: **(IMPORTANT)** Generate a unique secret key with this command and paste it into the file:
        ```bash
        openssl rand -base64 32
        ```
    *For advanced settings, such as performance tuning, see the [Advanced Configuration](#-advanced-configuration) section.*

4.  **Set permissions:**
    Paperless runs with a non-root user (default ID `1000`). Ensure the created directories have the correct permissions.
    ```bash
    sudo chown -R 1000:1000 data media export consume backups
    ```
    *Note: If your host user has a different ID than 1000, you can find your `UID` and `GID` with the `id` command and update the `USERMAP_UID` and `USERMAP_GID` variables in the `docker-compose.yml` file.*

### 2. Launch

Once the setup is complete, start all services in the background:

```bash
docker-compose up -d
```

---

## ⚙️ Advanced Configuration

### Performance Tuning

You can adjust the performance of Paperless-ngx by tuning specific environment variables in your `.env` file.

*   **`PAPERLESS_TASK_WORKERS`**: This variable controls the number of worker processes that handle background tasks, such as document consumption and processing. The default is set to `2`. If you have a powerful machine and a large volume of documents to process, you might consider increasing this number.
    ```env
    # in .env
    PAPERLESS_TASK_WORKERS=4
    ```

---

## 🛠️ Makefile Usage

A `Makefile` is included to simplify common operations.

| Command             | Description                                           |
| ------------------- | ----------------------------------------------------- |
| `make up`           | Start all services in detached mode.                  |
| `make down`         | Stop and remove all running services.                 |
| `make logs`         | Follow the logs of all services.                      |
| `make logs-web`     | Follow the logs for the Paperless webserver only.     |
| `make pull`         | Pull the latest Docker images for all services.       |
| `make clean-backups`| **(CAUTION)** Deletes all files in the `backups` directory. |
| `make help`         | Show this help message.                               |

---

## 🗄️ Backup and Restore

This setup includes two services for automated backups: one for the database and one for your media files (documents).

*   **`db-backup`**: Performs a daily backup of the PostgreSQL database.
*   **`media-backup`**: Creates a daily `.tar.gz` archive of the `media` directory.

All backups are stored in the `./backups` directory on the host machine.

### Restore Procedure

In the event of data loss or migration, follow these steps to restore your data.

#### 1. Restore Media Files

The media files are stored in `tar.gz` archives within the `backups` directory.

1.  **Identify the backup file** you want to restore (e.g., `media-backup-YYYYMMDD.tar.gz`).
2.  **Stop the running services** to prevent conflicts:
    ```bash
    make down
    ```
3.  **Extract the archive** into the `media` directory. This will overwrite existing files if there are any.
    ```bash
    # Replace with the correct backup file name
    tar -xvf backups/media-backup-YYYYMMDD.tar.gz -C media/
    ```

#### 2. Restore Database

The database backups are compressed SQL dump files.

1.  **Ensure the services are running**, especially the database container:
    ```bash
    make up
    ```
2.  **Identify the database backup file** you wish to restore from the `backups` directory.
3.  **Execute the restore command**. This command decompresses the backup and pipes it into the `psql` client inside the `paperless-db` container. The command will use the `POSTGRES_USER` and `POSTGRES_DB` variables from your `.env` file.

    ```bash
    # Replace with the correct backup file name
    gunzip < backups/your-db-backup.sql.gz | docker exec -i paperless-db psql -U $POSTGRES_USER -d $POSTGRES_DB
    ```

    *Note: This command assumes you are in the root of the project directory where the `backups` folder is located.*

4.  Once the command is complete, your database will be restored to the state of the backup. You can now restart all services to ensure everything is running correctly.
    ```bash
    make down && make up
    ```

