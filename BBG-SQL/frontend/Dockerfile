FROM node:14

WORKDIR /workspace/frontend

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --silent

# Copy the rest of the application code
COPY src/ src/

# Set the environment variable for React
ENV PORT=8083

# Expose the port the app runs on
EXPOSE 8083

# Start the application
CMD ["npm", "start"]
