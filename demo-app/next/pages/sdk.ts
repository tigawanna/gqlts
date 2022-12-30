import { createClient, getServiceUrl } from 'demo-app-backend-sdk-sdk';

const { graphqlUrl } = getServiceUrl('local');

export const demoAppBackendSdk = createClient({
  url: graphqlUrl,
});
