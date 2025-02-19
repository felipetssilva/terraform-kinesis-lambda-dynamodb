# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source code
COPY app.py .

# Expose port 80 (if your app is serving HTTP)
EXPOSE 80

# Run the application
CMD ["python", "app.py"]

