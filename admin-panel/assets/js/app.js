/**
 * Sahara Infosys - Admin Dashboard JavaScript
 * © Ibrahim Khatri since 2014
 */

const API_URL = 'http://localhost:8000/api';
const JWT_TOKEN = localStorage.getItem('auth_token');

// API Helper Functions
const api = {
    async get(endpoint) {
        try {
            const response = await fetch(`${API_URL}${endpoint}`, {
                headers: {
                    'Authorization': `Bearer ${JWT_TOKEN}`,
                    'Content-Type': 'application/json'
                }
            });
            return await response.json();
        } catch (error) {
            console.error('API Error:', error);
        }
    },

    async post(endpoint, data) {
        try {
            const response = await fetch(`${API_URL}${endpoint}`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${JWT_TOKEN}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            return await response.json();
        } catch (error) {
            console.error('API Error:', error);
        }
    },

    async put(endpoint, data) {
        try {
            const response = await fetch(`${API_URL}${endpoint}`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${JWT_TOKEN}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            return await response.json();
        } catch (error) {
            console.error('API Error:', error);
        }
    }
};

// Initialize Dashboard
document.addEventListener('DOMContentLoaded', async function() {
    console.log('Sahara Infosys Admin Dashboard Loaded');
    
    // Load dashboard data
    loadDashboardData();
});

// Load Dashboard Data
async function loadDashboardData() {
    try {
        const customers = await api.get('/customers');
        const jobs = await api.get('/jobs');
        const invoices = await api.get('/invoices');
        
        console.log('Dashboard Data Loaded', { customers, jobs, invoices });
    } catch (error) {
        console.error('Failed to load dashboard data:', error);
    }
}

// Utility Functions
function showAlert(message, type = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    const container = document.querySelector('.container-fluid');
    if (container) {
        container.insertBefore(alertDiv, container.firstChild);
    }
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR'
    }).format(amount);
}
