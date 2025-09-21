# Use the official Ballerina runtime image
FROM ballerina/ballerina:2201.12.9

# Set working directory
WORKDIR /app

# Copy the Ballerina project files
COPY . .

# Build the Ballerina project
RUN bal build

# Expose the port
EXPOSE 8080

# Run the application
CMD ["bal", "run", "server.bal"]
