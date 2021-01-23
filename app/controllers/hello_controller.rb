class HelloController < ApplicationController

def index
  redirect_to new_user_session_path , :notice => 'password has been changed on AWS Cognito '
  print "*************** in Hello Controller***********************\n"
   @greeting = "Index action says: Hello !"
   @user = current_user
   @clientId = ENV["AWS_COGNITO_CLIENT_ID"]
 end
end