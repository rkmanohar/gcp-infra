pipeline  {
    agent  {  label 'LAB-kjhsdoio4j5h39d' }
    
    options {
      buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    parameters {
       choice(
         name: 'project',
         choices: [
                'dummy-job',
                'hsbc-123456-global',
                'hsbc-123456-global1'
                ],
          description: 'Choose the project you want to deploy to')
        choice(
         name: 'gcpenv',
         choices: [
              'dev',
              'prod'
               ],
         description: 'Choose the environment')
     }
     
    environment {
       PROJECT = "$(params.project}"
       ENVIRONMENT = "${params.gcpenv}"
     }
     
     stages {
     
        stage('DEV - Init, Validate and Plan') {
            when {
                allOf {
                    not {
                      branch 'master'
                    }
                    not {
                      environment name: 'PROJECT', value: dummy-job'
                    }
                    environment name: 'ENVIRONMENT', value: 'dev'
                   }
                 }
              steps {
                 sh "ci/plan.sh \"${env.PROJECT}-${env.ENVIRONMENT}\""
                 
                 script {
                     pullRequest.comment("THIS MESSAGE IS FROM JENKINS DEV - Please review ${env.PROJECT}-${env.ENVIRONMENT} terraform plan at ${BUILD_URL}console")
                 
                 }
              }
           }
           
           stage('DEV - Approve Plan') {
               when {
                   allOf {
                       not {
                         environment name: 'PROJECT', value: 'dummy-job'
                       }
                       environment name: 'ENVIRONMENT', value: 'dev',
                       branch 'master'
                     }
                   }
                 steps {
                     sh "ci/plan.sh \"${env.PROJECT}-${env.ENVIRONMENT}\""
                     timeout(time:1, unit:'HOURS') {
                         input(message: "Deploy to ${env.PROJECT}-${env.ENVIRONMENT}?", ok: 'Deploy')
                     }
                  }
             }
         
            stage('DEV - Apply') {
               when {
                   allOf {
                       not {
                         environment name: 'PROJECT', value: 'dummy-job'
                       }
                       environment name: 'ENVIRONMENT', value: 'dev',
                       branch 'master'
                     }
                   }
                steps {
                    sh "ci/apply.sh \"${env.PROJECT}-${env.ENVIRONMENT}\""
                }
            }
         
           stage('PROD - Init, Validate and Plan') {
               when {
                   allOf {
                       not {
                         branch 'master'
                       }
                       environment name: 'ENVIRONMENT', value: 'prod'
                   }
               }
               steps {
                   sh "ci/plan.sh \"${env.PROJECT}-${env.ENVIRONMENT}\""
                   
                   script {
                       pullRequest.comment("THIS MESSAGE IS FROM JENKINS PROD - Please review ${env.PROJECT}-${env.ENVIRONMENT} terraform plan at ${BUILD_URL}console")
                       
                   }
               }
           }
          
          stage('PROD - Approve Plan') {
               when {
                   allOf {
                       not {
                         environment name: 'ENVIRONMENT', value: 'dummy-job'
                       }
                       environment name: 'ENVIRONMENT', value: 'prod'
                       branch 'master'
                   }
               }
              steps {
                  sh "ci/plan.sh \"${env.PROJECT}-${env.ENVIRONMENT}\""
                  timeout(time:1, unit:HOURS') {
                          input(message: "Deploy to "${env.PROJECT}-${env.ENVIRONMENT}?", ok: 'Deploy')
                                }
                                }
                                }
           stage('PROD - Apply') {
               when {
                   allOf {
                       not {
                         environment name: 'ENVIRONMENT', value: 'dummy-job'
                       }
                       environment name: 'ENVIRONMENT', value: 'prod'
                       branch 'master'
                   }
               }
              steps {
                  sh "ci/apply.sh \"${env.PROJECT}-${env.ENVIRONMENT}\""
              }
           }
                                }
                                
                                }
           
           
          
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
