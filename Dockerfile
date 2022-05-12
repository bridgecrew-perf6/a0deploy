ARG AUTH0_DEPLOY_CLI_VERSION=
ARG ENVIRONMENT=
ARG NODE_VERSION=14.16.0

FROM node:${NODE_VERSION}-alpine

ENV AUTH0_DEPLOY_CLI_VERSION=${AUTH0_DEPLOY_CLI_VERSION:-v7.12.1}
ENV ENVIRONMENT=${ENVIRONMENT:-dev}

LABEL Name="Auth0 Brazil Scripts"
LABEL Version="${NODE_VERSION}"

WORKDIR /tmp

RUN npm i -g auth0-deploy-cli@${AUTH0_DEPLOY_CLI_VERSION}

WORKDIR /app

ENTRYPOINT ["a0deploy"]

CMD ["--help"]
