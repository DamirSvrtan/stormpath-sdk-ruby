#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class Stormpath::Resource::Application < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  prop_accessor :name, :description

  resource_prop_reader :tenant, :accounts, :password_reset_tokens

  #
  # Sends a password reset email for the specified account username or email address.  The email will contain
  # a password reset link that the user can click or copy into their browser address bar.
  # <p/>
  # This method merely sends the password reset email that contains the link and nothing else.  You will need to
  # handle the link requests and then reset the account's password as described in the
  # {@link #verify_password_reset_token} RDoc.
  #
  # @param account_username_or_email a username or email address of an Account that may login to the application.
  # @return the account corresponding to the specified username or email address.
  # @see #account_username_or_email
  #
  def send_password_reset_email account_username_or_email

    password_reset_token = create_password_reset_token account_username_or_email;
    password_reset_token.account

  end

  # Verifies a password reset token in a user-clicked link within an email.
  # <p/>
  # <h2>Base Link Configuration</h2>
  # You need to define the <em>Base</em> link that will process HTTP requests when users click the link in the
  # email as part of your Application's Workflow Configuration within the Stormpath UI Console.  It must be a URL
  # served by your application's web servers.  For example:
  # <pre>
  # https://www.myApplication.com/passwordReset
  # </pre>
  # <h2>Runtime Link Processing</h2>
  # When an application user clicks on the link in the email at runtime, your web server needs to process the request
  # and look for an {@code spToken} request parameter.  You can then verify the {@code spToken}, and then finally
  # change the Account's password.
  # <p/>
  # Usage Example:
  # <p/>
  # Browser:
  # {@code GET https://www.myApplication/passwordReset?spToken=someTokenValueHere}
  # <p/>
  # Your code:
  # <pre>
  # token = #get the spToken query parameter
  #
  # account = application.verify_password_reset_token token
  #
  # //token has been verified - now set the new password with what the end-user submits:
  # account.password = user_submitted_new_password
  # account.save
  # </pre>
  #
  # @param token the verification token, usually obtained as a request parameter by your application.
  # @return the Account matching the specified token.
  def verify_password_reset_token token
    password_reset_tokens.get(token).account
  end

  #
  # Authenticates an account's submitted principals and credentials (e.g. username and password).  The account must
  # be in one of the Application's
  # <a href="http://www.stormpath.com/docs/managing-applications-login-sources">assigned Login Sources</a>.  If not
  # in an assigned login source, the authentication attempt will fail.
  # <h2>Example</h2>
  # Consider the following username/password-based example:
  # <p/>
  # <pre>
  # request = UsernamePasswordRequest.new username, submittedRawPlaintextPassword, nil
  # account = appToTest.authenticate_account(request).account
  # </pre>
  #
  # @param request the authentication request representing an account's principals and credentials (e.g.
  #                username/password) used to verify their identity.
  # @return the result of the authentication.  The authenticated account can be obtained from
  #         {@code result.}{@link Stormpath::Authentication::AuthenticationResult#account}.
  # @throws ResourceError if the authentication attempt fails.
  #
  def authenticate_account request
    response = Stormpath::Authentication::BasicAuthenticator.new data_store
    response.authenticate href, request
  end

  private

  def create_password_reset_token email
    password_reset_tokens.create email: email
  end
end
