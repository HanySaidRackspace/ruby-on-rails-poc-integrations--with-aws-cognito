class RegistrationsController < Devise::RegistrationsController

  def create
    print "*************** create RegistrationsController  ***********************\n"

    build_resource(sign_up_params)

    resource.save


    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)

        client =Aws::CognitoIdentityProvider::Client.new


        newUser = client.sign_up({ client_id: ENV["AWS_COGNITO_CLIENT_ID"] ,
                                                       username: params[:user][:email],
                                                       password: params[:user][:password]
                                                        })
        session[:is_new_user] = true
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def update

    print "*************** RegistrationsController  ***********************\n"

    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
    @user = User.find(current_user.id)

     if needs_password?
      successfully_updated = @user.update_with_password(account_update_params)
    else
      client = Aws::CognitoIdentityProvider::Client.new

      initiateAuthResp = client.initiate_auth({
                                    client_id: ENV["AWS_COGNITO_CLIENT_ID"],
                                    auth_flow: "USER_PASSWORD_AUTH" ,
                                    auth_parameters: {
                                      "USERNAME" => params[:user][:email],
                                      "PASSWORD" => params[:user][:current_password]
                                    }
                                  })

      print "******************** get token ****************************"

      print initiateAuthResp.authentication_result.access_token

      print "******************** token  end print  ****************************"

      changePasswordResp = client.change_password({         previous_password: params[:user][:current_password],
                                              proposed_password: params[:user][:password_confirmation] ,
                                              access_token: initiateAuthResp.authentication_result.access_token
                                            })

      print "******************** change_password  ****************************"
      print  changePasswordResp

      successfully_updated = @user.update_attributes(account_update_params)

      account_update_params.delete('password')
      account_update_params.delete('password_confirmation')
      account_update_params.delete('current_password')

    end

    if successfully_updated
      set_flash_message :notice, :updated
      sign_in @user, :bypass => true
      redirect_to edit_user_registration_path
    else
      render 'edit'
    end
  end

  private

  def needs_password?
    @user.email != params[:user][:email] || params[:user][:password].present?
  end
end