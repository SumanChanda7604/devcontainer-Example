// frontend/src/App.js
import React, { useState } from 'react';
import axios from 'axios'; // Ensure this line is present and correct
import './App.css';

function App() {
  const [dbName, setDbName] = useState('');
  const [schema, setSchema] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSchema(null);

    try {
      const response = await axios.post('http://localhost:8083/get-schema', { db_name: dbName });
      setSchema(response.data);
    } catch (error) {
      setError('Error fetching schema: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Database Schema Viewer</h1>
        <form onSubmit={handleSubmit}>
          <label>
            Database Name:
            <input type="text" value={dbName} onChange={(e) => setDbName(e.target.value)} required />
          </label>
          <button type="submit">Get Schema</button>
        </form>
        {loading && <p>Loading...</p>}
        {error && <p style={{ color: 'red' }}>{error}</p>}
        {schema && (
          <div className="schema">
            <h2>Database: {dbName}</h2>
            {Object.keys(schema).map((tableName) => (
              <div key={tableName}>
                <h3>Table: {tableName}</h3>
                <table>
                  <thead>
                    <tr>
                      <th>Column Name</th>
                      <th>Data Type</th>
                    </tr>
                  </thead>
                  <tbody>
                    {schema[tableName].map((column) => (
                      <tr key={column.column_name}>
                        <td>{column.column_name}</td>
                        <td>{column.data_type}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
