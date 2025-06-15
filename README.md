# Market Data Service

A production-ready microservice that fetches market data, processes it through a streaming pipeline, and serves it via REST APIs.

## 🚀 Overview

This service provides real-time market data fetching with the following features:
- RESTful API for retrieving latest prices and scheduling polling jobs
- Kafka-based streaming pipeline for real-time data processing
- Moving average calculation using event-driven architecture
- PostgreSQL for data persistence
- Docker containerization for easy deployment

## 📋 Prerequisites

- Docker and Docker Compose
- Python 3.11+
- API key for your chosen market data provider (Alpha Vantage, Yahoo Finance, or Finnhub)

## 🛠️ Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/piyush12kunjilwar/f-Blockhouse-Capital-Software-Engineer-Intern-.git
   cd market-data-service
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys and configuration
   ```

3. **Start the services**
   ```bash
   docker-compose up --build
   ```

4. **Initialize the database**
   ```bash
   docker-compose exec api python scripts/init_db.py
   ```

The API will be available at `http://localhost:8000`

## 📚 API Documentation

### Endpoints

#### Get Latest Price
```http
GET /prices/latest?symbol={symbol}&provider={provider?}
```

**Parameters:**
- `symbol` (required): Stock symbol (e.g., AAPL, MSFT)
- `provider` (optional): Data provider (alpha_vantage, yahoo_finance, finnhub)

**Response:**
```json
{
  "symbol": "AAPL",
  "price": 150.25,
  "timestamp": "2024-03-20T10:30:00Z",
  "provider": "alpha_vantage"
}
```

#### Schedule Polling Job
```http
POST /prices/poll
Content-Type: application/json

{
  "symbols": ["AAPL", "MSFT"],
  "interval": 60,
  "provider": "alpha_vantage"
}
```

**Response (202 Accepted):**
```json
{
  "job_id": "poll_123",
  "status": "accepted",
  "config": {
    "symbols": ["AAPL", "MSFT"],
    "interval": 60
  }
}
```

### Error Responses

| Status Code | Description |
|------------|-------------|
| 400 | Bad Request - Invalid parameters |
| 404 | Not Found - Symbol not found |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

### Rate Limiting

- Alpha Vantage: 5 calls per minute
- Yahoo Finance: 2000 calls per hour
- Finnhub: 60 calls per minute (free tier)

## 🏗️ Architecture

### System Architecture

The service follows a microservices architecture with the following components:

1. **FastAPI Service**: Handles HTTP requests and orchestrates data flow
2. **PostgreSQL**: Stores raw market data, processed prices, and moving averages
3. **Apache Kafka**: Message broker for event-driven processing
4. **Market Data Providers**: External APIs for fetching real-time prices

### Data Flow

1. Client requests latest price via REST API
2. Service checks cache/database for recent data
3. If data is stale, fetches from market data provider
4. Raw response stored in PostgreSQL
5. Price event published to Kafka topic `price-events`
6. Consumer calculates 5-point moving average
7. Moving average stored in `symbol_averages` table

### Database Schema

#### Tables

**raw_market_data**
- `id`: UUID primary key
- `symbol`: VARCHAR(10)
- `provider`: VARCHAR(50)
- `raw_response`: JSONB
- `created_at`: TIMESTAMP

**price_points**
- `id`: UUID primary key
- `symbol`: VARCHAR(10)
- `price`: DECIMAL(10,2)
- `timestamp`: TIMESTAMP
- `provider`: VARCHAR(50)

**symbol_averages**
- `id`: UUID primary key
- `symbol`: VARCHAR(10)
- `moving_average_5`: DECIMAL(10,2)
- `calculated_at`: TIMESTAMP
- `data_points`: JSONB

**polling_jobs**
- `id`: UUID primary key
- `job_id`: VARCHAR(100) UNIQUE
- `symbols`: JSONB
- `interval`: INTEGER
- `provider`: VARCHAR(50)
- `status`: VARCHAR(20)
- `created_at`: TIMESTAMP

## 🔧 Configuration

### Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:password@postgres:5432/marketdata

# Kafka
KAFKA_BOOTSTRAP_SERVERS=kafka:29092
KAFKA_TOPIC_PRICES=price-events

# Market Data Providers
ALPHA_VANTAGE_API_KEY=your_api_key_here
FINNHUB_API_KEY=your_api_key_here

# Application
API_PORT=8000
LOG_LEVEL=INFO
```

## 🐳 Docker Configuration

The service uses multi-stage Docker builds for optimization:

```yaml
services:
  api:
    build: .
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - kafka

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: marketdata
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password

  kafka:
    image: confluentinc/cp-kafka:latest
    depends_on:
      - zookeeper

  zookeeper:
    image: confluentinc/cp-zookeeper:latest
```

## 🧪 Testing

Run the test suite:

```bash
# Unit tests
docker-compose exec api pytest tests/unit

# Integration tests
docker-compose exec api pytest tests/integration

# All tests with coverage
docker-compose exec api pytest --cov=app tests/
```

## 📊 Monitoring

### Health Check
```http
GET /health
```

### Metrics
The service exposes Prometheus metrics at `/metrics` (optional feature)

## 🚨 Troubleshooting

### Common Issues

1. **Kafka Connection Issues**
   - Ensure Kafka and Zookeeper are running
   - Check KAFKA_BOOTSTRAP_SERVERS configuration
   - Verify network connectivity between containers

2. **Database Connection Errors**
   - Check DATABASE_URL format
   - Ensure PostgreSQL is running
   - Verify database migrations have run

3. **API Rate Limiting**
   - Implement exponential backoff
   - Use caching to reduce API calls
   - Consider upgrading to paid tier

### Logs

View logs for debugging:
```bash
# API logs
docker-compose logs -f api

# Kafka consumer logs
docker-compose logs -f consumer

# All services
docker-compose logs -f
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.
