pipeline {
  agent any
  
  options {
    timeout(time: 1, unit: 'HOURS')
    ansiColor('xterm')
    timestamps()
  }
  
  stages {
    stage('Завантаження конфігурації') {
      steps {
        script {
          // Завантажуємо конфігурацію з файлу
          configFileProvider([
            configFile(fileId: 'jenkins-config', 
                     variable: 'JENKINS_CONFIG')
          ]) {
            // Завантажуємо властивості в змінні оточення
            def props = readProperties file: env.JENKINS_CONFIG
            env.PROJECT_PATH = props.PROJECT_PATH
            env.DB_NAME = props.DB_NAME
            env.DB_HOST = props.DB_HOST
            env.APACHE_PORT = props.APACHE_PORT
          }
        }
      }
    }
    
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    
    stage('Налаштування бази даних') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'mysql-credentials', 
                                       usernameVariable: 'MYSQL_USER', 
                                       passwordVariable: 'MYSQL_PASSWORD')]) {
          sh """
            mysql -h \$DB_HOST -u \$MYSQL_USER -p\$MYSQL_PASSWORD -e "CREATE DATABASE IF NOT EXISTS \$DB_NAME;"
            if [ -f 'db/bloodbank.sql' ]; then
              mysql -h \$DB_HOST -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$DB_NAME < db/bloodbank.sql
            fi
          """
        }
      }
    }
    
    stage('Розгортання') {
      steps {
        dir(env.PROJECT_PATH) {
          deleteDir()
          sh "cp -r \$WORKSPACE/client/* ."
        }
        
        configFileProvider([
          configFile(fileId: 'php-config', 
                   targetLocation: "${env.PROJECT_PATH}/config.php",
                   variable: 'CONFIG_FILE')
        ]) {
          sh "chmod 644 ${env.PROJECT_PATH}/config.php"
        }
      }
    }
    
    stage('Тестування') {
      steps {
        script {
          def response = httpRequest url: "http://localhost:${env.APACHE_PORT}"
          if (response.status != 200) {
            error "Веб-сервер не відповідає коректно"
          }
        }
      }
    }
    
    stage('Тестування продуктивності') {
      steps {
        performance persistConstraintLog: true,
          sourceDataFiles: '**/*.jtl'
      }
    }
  }
  
  post {
    always {
      cleanWs()
    }
  }
}
