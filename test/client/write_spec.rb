require "stormpath-sdk"

include Stormpath::Authentication

describe "WRITE Operations" do

  before(:all) do
    apiKey = ApiKey.new 'myApkiKeyId', 'myApkiKeySecret'
    @client = Client.new apiKey
    @data_store = @client.data_store
    @create_account = false
    @update_account = false
    @update_application = false
    @update_directory = false
    @update_group = false
    @create_application = false
    @verify_email = false
    @send_password_reset_email = false
    @verify_password_reset_token = false
    @create_account_with_group_membership = false
    @create_group_membership_from_account = false
    @create_group_membership_from_group = false
    @update_group_membership_with_deletion = false
  end

  it "application should be able to authenticate" do

    href = 'applications/fzyWJ5V_SDORGPk4fT2jhA'
    application = @data_store.get_resource href, Application

    result = application.authenticate_account UsernamePasswordRequest.new 'tootertest', 'super_P4ss', nil

    result.should be_kind_of AuthenticationResult

    result.get_account.should be_kind_of Account
  end

  it "application should NOT be able to authenticate and catch the error" do

    begin

      href = 'applications/fzyWJ5V_SDORGPk4fT2jhA'
      application = @data_store.get_resource href, Application
      result = application.authenticate_account UsernamePasswordRequest.new 'tootertest', 'WRONG_PASS', nil

    rescue ResourceError => re
      p '** Authentication Error **'
      p 'Message: ' + re.message
      p 'HTTP Status: ' + re.get_status.to_s
      p 'Developer Message: ' + re.get_developer_message
      p 'More Information: ' + re.get_more_info
      p 'Error Code: ' + re.get_code.to_s
    end

    result.should_not be_kind_of AuthenticationResult
  end

  it "directory should be able to create account" do

    if (@create_account)

      href = 'directories/wDTY5jppTLS2uZEAcqaL5A'
      directory = @data_store.get_resource href, Directory

      account = @data_store.instantiate Account, nil
      account.set_email 'rubysdk@email.com'
      account.set_given_name 'Ruby'
      account.set_password 'super_P4ss'
      account.set_surname 'Sdk'
      account.set_username 'rubysdk'

      result = directory.create_account account

      result.should be_kind_of Account

    end

  end

  it "account should be updated" do

    if (@update_account)

      href = 'accounts/ije9hUEKTZ29YcGhdG5s2A'
      account = @data_store.get_resource href, Account

      mod_value = 'Modified at: ' + Time.now.to_s
      account.set_middle_name mod_value
      account.set_status Status::ENABLED

      account.save

      account.get_middle_name.should == mod_value

    end

  end

  it "application should be updated" do

    if (@update_application)

      href = 'applications/fzyWJ5V_SDORGPk4fT2jhA'
      application = @data_store.get_resource href, Application

      application.set_name application.get_name + ' Modified'
      application.set_status Status::ENABLED

      application.save

      application.get_name.should be_kind_of String

    end

  end

  it "directory should be updated" do

    if (@update_directory)

      href = 'directories/wDTY5jppTLS2uZEAcqaL5A'
      directory = @data_store.get_resource href, Directory

      directory.set_name directory.get_name + ' Modified'
      directory.set_status Status::ENABLED

      directory.save

      directory.get_name.should be_kind_of String

    end

  end

  it "group should be updated" do

    if (@update_group)

      href = 'groups/mCidbrAcSF-VpkNfOVvJkQ'
      group = @data_store.get_resource href, Group

      group.set_name group.get_description + ' Modified'
      group.set_status Status::ENABLED

      group.save

      group.get_name.should be_kind_of String

    end

  end

  it "application should be created" do

    if (@create_application)

      tenant = @client.current_tenant

      application = @data_store.instantiate Application, nil
      application.set_name 'Test Application Creation'
      application.set_description 'Test Application Description'

      result = tenant.create_application application

      result.should be_kind_of Application

    end

  end

  it "email should get verified" do

    if (@verify_email)

      verification_token = 'ujhNWAIVT2Wtfk-no3ajtw'

      tenant = @client.current_tenant

      result = tenant.verify_account_email verification_token

      result.should be_kind_of Account

    end

  end

  it "password reset email should be sent" do

    if (@send_password_reset_email)

      href = 'applications/fzyWJ5V_SDORGPk4fT2jhA'
      application = @data_store.get_resource href, Application

      result = application.send_password_reset_email 'rubysdk@email.com'

      result.should be_kind_of Account

    end

  end

  it "password reset token should be verified" do

    if (@verify_password_reset_token)

      href = 'applications/fzyWJ5V_SDORGPk4fT2jhA'
      application = @data_store.get_resource href, Application

      result = application.verify_password_reset_token 'N0Zt1W9jTW2hP37XAE1jTQ'

      result.should be_kind_of Account

    end

  end

  it "account should be created linked to a group" do

    if (@create_account_with_group_membership)

      directory_href = 'directories/wDTY5jppTLS2uZEAcqaL5A'
      directory = @data_store.get_resource directory_href, Directory

      group_href = 'groups/mCidbrAcSF-VpkNfOVvJkQ'
      group = @data_store.get_resource group_href, Group

      account = @data_store.instantiate Account, nil
      account.set_email 'rubysdkwithgroup@email.com'
      account.set_given_name 'Ruby'
      account.set_password 'super_P4ss'
      account.set_surname 'Sdk With Group'
      account.set_username 'rubysdkwithgroup'

      begin

        directory.create_account account
        account.add_group group

      rescue ResourceError => re

        false.should be true

      end

      group_added = false
      account.get_groups.each { |tmpGroup|

        if tmpGroup.get_href.include? group_href

          group_added = true
          break
        end
      }

      group_added.should be true

    end

  end


  it "account should be linked to specified group" do

    if (@create_group_membership_from_account)

      group_href = 'groups/mCidbrAcSF-VpkNfOVvJkQ'
      group = @data_store.get_resource group_href, Group

      account_href = 'accounts/ije9hUEKTZ29YcGhdG5s2A'
      account = @data_store.get_resource account_href, Account

      account.add_group group

      group_linked = false
      account.get_group_memberships.each { |group_membership|

        group = group_membership.get_group

        if (!group.nil? and group.get_href.include? group_href)
          group_linked = true
          break
        end
      }

      group_linked.should == true

    end

  end


  it "group should be linked to specified account" do

    if (@create_group_membership_from_group)

      group_href = 'groups/mCidbrAcSF-VpkNfOVvJkQ'
      group = @data_store.get_resource group_href, Group

      account_href = 'accounts/ije9hUEKTZ29YcGhdG5s2A'
      account = @data_store.get_resource account_href, Account

      group.add_account account

      accountLinked = false
      group.get_accounts.each { |tmpAccount|

        if (tmpAccount.get_href.include? account_href)
          accountLinked = true
          break
        end
      }

      accountLinked.should == true

    end

  end

  it "group membership should be updated with deletion/creation" do

    if (@update_group_membership_with_deletion)

      group_href = 'groups/mCidbrAcSF-VpkNfOVvJkQ'
      group = @data_store.get_resource group_href, Group

      account_href = 'accounts/ije9hUEKTZ29YcGhdG5s2A'
      account = @data_store.get_resource account_href, Account

      group_linked = false
      group_membership = nil
      account.get_group_memberships.each { |tmp_group_membership|

        group_membership = tmp_group_membership
        tmp_group = group_membership.get_group

        if (!tmp_group.nil? and tmp_group.get_href.include? group_href)
          group_linked = true
          break
        end
      }

      if (!group_linked)
        group_membership.delete
        group.add_account account
      end

      account.get_group_memberships.each { |tmp_group_membership|

        tmp_group = tmp_group_membership.get_group

        if (!tmp_group.nil? and tmp_group.get_href.include? group_href)
          group_membership = tmp_group_membership
          break
        end
      }

      group_membership.get_group.get_href.should include group_href

    end

  end

end