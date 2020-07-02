#!/usr/bin/groovy
/* -*- mode: groovy; -*-
 * lxtestbox pipeline
 */


pipeline {

	parameters {
		string(name: 'CONTAINERVERSION', defaultValue: 'stable', description: 'the version of the used Docker container [stable|latest]')
	}

	agent any;

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
			}
		}
	}
}
