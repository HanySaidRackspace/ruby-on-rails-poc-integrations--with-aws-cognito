class HelloController < ApplicationController

def index
  print "*************** in Hello Controller***********************\n"
   @greeting = "Index action says: Hello !"
   @user = current_user
   @clientId = ENV["AWS_COGNITO_CLIENT_ID"]
 end
end