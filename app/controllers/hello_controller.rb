class HelloController < ApplicationController

def index

   @greeting = "Index action says: Hello !"
   @user = current_user
   @clientId = ENV["AWS_COGNITO_CLIENT_ID"]
 end
end