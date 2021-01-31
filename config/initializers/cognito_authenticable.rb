require 'aws-sdk'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class CognitoAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          session[:cognito_error_message] =nil
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
              #session[:cognito_access_token] = resp.authentication_result.access_token
              #session[:cognito_id_token] = resp.authentication_result.id_token
              #session[:cognito_refresh_token] = resp.authentication_result.refresh_token

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
          rescue => ex
            print ex
            session[:cognito_error_message] = ex.message

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