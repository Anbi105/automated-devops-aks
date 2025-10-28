# app/Dockerfile
# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Python application code into the container
COPY app.py /app/

# Install the Flask library
RUN pip install flask

# Expose the port the Flask app runs on
EXPOSE 5000

# Command to run the application when the container starts
CMD ["python", "app.py"]