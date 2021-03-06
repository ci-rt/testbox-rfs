#!/usr/bin/groovy
/* -*- mode: groovy; -*-
 * lxtestbox pipeline
 */


pipeline {

	parameters {
		string(name: 'CONTAINERVERSION', defaultValue: 'stable', description: 'the version of the used Docker container [stable|latest]')
	}

	agent any;

	triggers {
		pollSCM('H */4 * * 1-5')
	}

	options {
		timestamps()
		/* keep 2 artifacts */
		buildDiscarder(logRotator(numToKeepStr: '2'))
	}

	stages {
		stage('generateTestboxImage') {
			agent {
				node {
					label 'docker'
				}
			}
			steps {
				lock('ELBE-Initvm') {   /* needs plugin 'Lockable Resources' */
					script {
						sh "./genTestbox.sh ${params.CONTAINERVERSION}"
					}
				} /* end of lock */
			}
			post {
				success {
					/* archive the artifacts
					*/
					archiveArtifacts '*.txt,*.gz,*.iso,*.xml,*.tgz,*.img'
				}
				failure {
					/* stop the used container */
					sh "docker stop ELBEVM-`id -u`"
					sh "docker rm ELBEVM-`id -u`"
				}
			}
		}
	}
}
