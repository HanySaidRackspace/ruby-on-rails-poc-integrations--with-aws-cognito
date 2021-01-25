require 'aws-sdk'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class CognitoAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          client = Aws::CognitoIdentityProvider::Client.new
          #byebug
          print "*************** CognitoAuthenticatable   ***********************\n"
          begin


            resp = client.initiate_auth({
                                          client_id: ENV["AWS_COGNITO_CLIENT_ID"],
                                          auth_flow: "USER_PASSWORD_AUTH" ,
                                          auth_parameters: {
                                            "USERNAME" => email,
                                            "PASSWORD" => password
                                          }
                                        })


            if resp

              print resp

              session[:is_new_user] = false

              user = User.where(email: email).try(:first)
              if user
                success!(user)
              else
                user = User.create(email: email, password: password, password_confirmation: password)

                if user.valid?
                  success!(user)
                else
                  return fail(:failed_to_create_user)
                end
              end
            else

              return fail(:unknow_cognito_response)
            end

          rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException => e

            return fail(:invalid_login)

          rescue

            return fail(:unknow_cognito_error)

          end

        end
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

    end
  end
end