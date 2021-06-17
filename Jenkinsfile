#!/usr/bin/groovy
/* -*- mode: groovy; -*-
 * lxtestbox pipeline
 */


pipeline {

	parameters {
		string(name: 'CONTAINERVERSION', defaultValue: 'stable', description: 'the version of the used Docker container [stable|latest]')
		string(name: 'VARIANTS', defaultValue: 'tb-io-testing-bbb', description: 'additional variants to build e.g. tb-io-testing-bbb')
	}

	agent { label 'local' };

	triggers {
		pollSCM('H */4 * * 1-5')
	}

	options {
		timestamps()
		/* keep 2 artifacts */
		buildDiscarder(logRotator(numToKeepStr: '2'))
	}

        environment {
                // get a unique ID for this pipeline run
                suiteRunId = UUID.randomUUID().toString()
        }

	stages {
		stage('generateTestboxImage') {
			agent {
				node {
					label 'docker'
				}
			}
			steps {
				script {
					sh "./genTestbox.sh ${params.CONTAINERVERSION} ${suiteRunId} ${params.VARIANTS}"
				}
			}
			post {
				success {
					/* archive the artifacts
					*/
					archiveArtifacts '*.txt,*.gz,*.iso,*.xml,*.tgz,*.img'
				}
				failure {
					/* stop the used container */
					sh "docker stop ELBEVM-`id -u`-${suiteRunId}"
					sh "docker rm ELBEVM-`id -u`-${suiteRunId}"
				}
			}
		}
	}
}
