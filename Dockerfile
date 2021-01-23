# Run on nginx
FROM nginx:alpine

# Copy index file to nginx folder
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80 for the app to work
EXPOSE 80