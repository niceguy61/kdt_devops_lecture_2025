import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState('Loading...');
  const [users, setUsers] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Health check
    fetch('/api/health')
      .then(res => res.json())
      .then(data => setMessage(data.message))
      .catch(err => setError('Backend connection failed'));
    
    // Get users
    fetch('/api/users')
      .then(res => res.json())
      .then(data => setUsers(data))
      .catch(err => setError('Failed to load users'));
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 CI/CD Demo Application</h1>
        <p className="version">Version 1.0.0</p>
      </header>
      
      <main className="App-main">
        <section className="status-section">
          <h2>Backend Status</h2>
          {error ? (
            <p className="error">{error}</p>
          ) : (
            <p className="success">{message}</p>
          )}
        </section>

        <section className="users-section">
          <h2>Users List</h2>
          {users.length > 0 ? (
            <ul className="users-list">
              {users.map(user => (
                <li key={user.id} className="user-item">
                  <strong>{user.name}</strong>
                  <span>{user.email}</span>
                  <small>{new Date(user.created_at).toLocaleDateString()}</small>
                </li>
              ))}
            </ul>
          ) : (
            <p>No users found</p>
          )}
        </section>
      </main>

      <footer className="App-footer">
        <p>Powered by Docker Compose + GitHub Actions</p>
      </footer>
    </div>
  );
}

export default App;
