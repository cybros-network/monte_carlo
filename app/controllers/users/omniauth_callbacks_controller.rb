# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def failure
      flash[:alert] = t("users.omniauth_callbacks.unexpected_failure")
      redirect_to new_user_session_url
    end

    def siwe
      handle_auth "SIWE"
    end

    private
      def handle_auth(kind)
        identity = Identity.where(provider: auth.provider, extern_uid: auth.uid).first

        if identity
          if user_signed_in?
            if current_user != identity.user
              flash[:alert] = t("users.omniauth_callbacks.connection_occupied", kind: kind)
              redirect_to account_profile_url
              return
            else
              identity.update(identity_params)

              flash[:notice] = t("users.omniauth_callbacks.connection_updated", kind: kind)
              redirect_to account_profile_url
              return
            end
          else
            set_flash_message :notice, :success, kind: kind
            sign_in_and_redirect identity.user, event: :authentication
            return
          end
        end

        if user_signed_in?
          identity = current_user.identities.build identity_params
          if identity.save
            flash[:notice] = t("users.omniauth_callbacks.connection_saved", kind: kind)
          else
            flash[:alert] = t("users.omniauth_callbacks.connection_fail_to_save", kind: kind)
          end
          redirect_to account_profile_url
        else
          user = User.new user_params_of(kind)
          user.identities.build identity_params

          if user.save!
            set_flash_message :notice, :success, kind: kind
            sign_in_and_redirect user, event: :authentication
          else
            flash[:alert] = t("users.omniauth_callbacks.unexpected_failure")
            redirect_to new_user_session_url
          end
        end
      end

      def auth
        request.env["omniauth.auth"]
      end

      def identity_params
        # expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
        {
          provider: auth.provider,
          extern_uid: auth.uid,
        }
      end

      def user_params_of(kind)
        case kind
        when "SIWE"
          address = auth.uid.split(":").last
          {
            name: address.truncate(12, omission: "...#{address.last(4)}"),
            password: Devise.friendly_token(16)
          }
        else
          raise ArgumentError, "Unhandled kind `#{kind}`"
        end
      end
  end
end
