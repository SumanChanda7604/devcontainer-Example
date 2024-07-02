FROM python:3.9-slim

WORKDIR /workspace/backend

# Install build tools and sudo
RUN apt-get update && \
    apt-get install -y gcc g++ unixodbc-dev sudo && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8082

CMD ["python", "app.py"]
