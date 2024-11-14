# Use an official Python runtime as a parent image
FROM python:3.8-slim AS builder

# Set the working directory in the container
WORKDIR /app

# Copy only the requirements file to leverage Docker cache
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . .

# Use a smaller base image for the final stage
FROM python:3.8-slim AS final

# Set the working directory in the container
WORKDIR /app

# Create a non-root user
RUN useradd -m appuser

# Copy the installed packages and application code from the builder stage
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# Ensure the database file has the correct permissions
RUN chown -R appuser:appuser /app

# Expose port 8000 to the outside world
EXPOSE 8000

# Define environment variable
ENV APP_ENV=dev

# Switch to the non-root user
USER appuser

# Command to run the FastAPI application using uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
