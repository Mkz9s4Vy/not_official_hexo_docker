FROM node:23-alpine

# Set the server port as an environmental
ENV HEXO_SERVER_PORT=4000

# Install requirements
RUN apk add --update npm && \
    npm install -g hexo-cli

# Set workdir
WORKDIR /app

# Expose Server Port
EXPOSE ${HEXO_SERVER_PORT}

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s CMD wget --no-verbose --tries=1 --spider http://localhost:${HEXO_SERVER_PORT}/ || exit 1


CMD ["sh", "-c", "if [ \"$(ls -A /app)\" ]; then \
    echo \"***** App directory exists and has content, continuing *****\"; \
  else \
    echo \"***** App directory is empty, initialising with hexo *****\" && \
    hexo init && \
    echo \"***** Updating and fixing npm *****\" && \
    npm update && \
    npm audit fix && \
    echo \"***** Installing theme Butterfly *****\" && \
    npm i hexo-theme-butterfly && \
    npm install hexo-renderer-pug hexo-renderer-stylus --save && \
    npm install --production; \
  fi; \
  if [ ! -f /app/requirements.txt ]; then \
    echo \"***** App directory contains no requirements.txt file, continuing *****\"; \
  else \
    echo \"***** App directory contains a requirements.txt file, installing npm requirements *****\" && \
    cat /app/requirements.txt | xargs npm install --save --production; \
  fi; \
  echo \"***** Generating static site *****\" && \
  hexo generate && \
  echo \"***** Starting server on port ${HEXO_SERVER_PORT} *****\" && \
  hexo server -s -p ${HEXO_SERVER_PORT}"]
