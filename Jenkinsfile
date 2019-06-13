pipeline {
    agent {label 'docker-enabled'}
    parameters { string(name: 'movie_name', defaultValue: '-enter value-', description: 'enter movie name') }
    stages {
        stage('Docker Build') {
            steps {
                script {
                    //build image with curl and bash
                   def dockerImage = docker.build("imdbMovieDetails:latest", "./Dockerfile")
                }
            }
        }
        stage('fetch movie details') {
            steps {
                script {
                    dockerImage.inside{
                        ./movieInformation.sh "${params.movie_name}"
                    }
                }
            }
        }
    }
}