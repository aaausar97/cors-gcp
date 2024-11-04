# Use an official Node.js runtime as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Clone your GitHub repository
RUN git clone https://github.com/aaausar97/cors-gcp.git .

# Install dependencies
RUN npm install

# Expose port 8080 to the host
EXPOSE 8080

# Start the server
CMD ["npm", "run", "start"]

