const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.status(200).send('CI/CD Pipeline is working correctly!');
});

// Example API endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

module.exports = app;