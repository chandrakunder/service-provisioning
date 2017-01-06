package com.manywho.services.provisioning.email;

import com.amazonaws.services.identitymanagement.model.*;
import com.manywho.sdk.api.run.elements.config.ServiceRequest;
import com.manywho.sdk.services.actions.ActionCommand;
import com.manywho.sdk.services.actions.ActionResponse;
import com.manywho.services.provisioning.ApplicationConfiguration;
import com.manywho.services.provisioning.ServiceConfiguration;
import com.manywho.services.provisioning.factories.AmazonFactory;
import javax.inject.Inject;

public class ProvisionEmailCommand implements ActionCommand<ServiceConfiguration, ProvisionEmail, ProvisionEmail.Input, ProvisionEmail.Output> {
    private AmazonFactory amazonFactory;
    private ApplicationConfiguration applicationConfiguration;
    private SesSmtpCredentialGenerator sesSmtpCredentialGenerator;

    @Inject
    public ProvisionEmailCommand(AmazonFactory amazonFactory, SesSmtpCredentialGenerator sesSmtpCredentialGenerator,
                                 ApplicationConfiguration applicationConfiguration) {
        this.amazonFactory = amazonFactory;
        this.sesSmtpCredentialGenerator = sesSmtpCredentialGenerator;
        this.applicationConfiguration = applicationConfiguration;
    }

    @Override
    public ActionResponse<ProvisionEmail.Output> execute(ServiceConfiguration configuration, ServiceRequest request, ProvisionEmail.Input input) {

        this.amazonFactory.getAmazonIdentityManagementClient()
                .createUser(new CreateUserRequest(input.getTenant().toString()));

        AttachUserPolicyRequest policyRequest = new AttachUserPolicyRequest();
        policyRequest.withUserName(input.getTenant().toString()).withPolicyArn(applicationConfiguration.getAwsSesPolicy());

        this.amazonFactory.getAmazonIdentityManagementClient().attachUserPolicy(policyRequest);

        CreateAccessKeyResult createAccessKeyResult = this.amazonFactory.getAmazonIdentityManagementClient()
                .createAccessKey(new CreateAccessKeyRequest(input.getTenant().toString()));

        String keyId = createAccessKeyResult.getAccessKey().getAccessKeyId();
        String password = sesSmtpCredentialGenerator.getSmtpPassword(createAccessKeyResult.getAccessKey().getSecretAccessKey());

        return new ActionResponse<>(new ProvisionEmail.Output(applicationConfiguration.getAwsSesHost(),
                applicationConfiguration.getAwsSesTransport(), applicationConfiguration.getAwsSesPort(),
                keyId, password));
    }
}
