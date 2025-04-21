FROM jenkins/jenkins:lts

USER root

# Встановлення необхідних залежностей
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    default-mysql-client \
    software-properties-common

# Налаштування Docker репозиторію
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

# Додавання Docker репозиторію
RUN echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# Встановлення Docker
RUN apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Встановлення Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Створення необхідних директорій та налаштування прав
RUN mkdir -p /var/www/html && \
    chown -R jenkins:jenkins /var/www && \
    chmod -R 755 /var/www

# Додавання jenkins користувача до docker групи
RUN usermod -aG docker jenkins

# Очищення кешу apt
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
