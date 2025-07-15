# Use a lightweight NGINX web server image
FROM nginx:1.25-alpine

# Copy the contents of the current directory into the NGINX public directory
COPY . /usr/share/nginx/html

# NGINX listens on port 80 by default
EXPOSE 80