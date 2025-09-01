# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /usr/src/app

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apt-get update && apt-get install gnupg wget -y && \
  wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install google-chrome-stable -y --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*


# install pnpm
RUN npm install -g pnpm
RUN alias npm=pnpm


  # Copy package.json and package-lock.json (if present)
# to leverage Docker cache for dependency installation
COPY package*.json ./


# Install application dependencies
RUN npm install

RUN npx puppeteer browsers install chrome

# Copy the rest of the application source code
COPY src src
COPY tsconfig.json tsconfig.json
COPY package.json package.json
COPY pnpm-lock.yaml pnpm-lock.yaml

RUN npm run build

ENV PORT=3001

# Expose the port your application listens on
EXPOSE 3001

# Define the command to run your application
CMD [ "node", "server.js" ]
