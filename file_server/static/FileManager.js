/**
 * FileManager - Simple extraction of existing file management functions
 */
class FileManager {
    constructor() {
        // Bind methods
        this.loadFiles = this.loadFiles.bind(this);
        this.deleteFile = this.deleteFile.bind(this);
        this.deleteAllFiles = this.deleteAllFiles.bind(this);
        this.downloadAllFiles = this.downloadAllFiles.bind(this);
        this.generatePDFReport = this.generatePDFReport.bind(this);
        this.resetAllData = this.resetAllData.bind(this);
    }

    // Load files - extracted from existing script.js
    loadFiles() {
        fetch('/files')
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to fetch files');
                }
                return response.json();
            })
            .then(data => {
                // Categorize files (same logic as existing script.js)
                const pdfFiles = data.files.filter(f => f.startsWith('data_quality_report') && f.endsWith('.pdf'));
                const processedFiles = data.files.filter(f => f.startsWith('processed_') && f.endsWith('.csv'));
                const anomalyFiles = data.files.filter(f => f.startsWith('anomaly_report_') && f.endsWith('.csv'));
                
                // Display files (same logic as existing)
                const pdfFilesList = document.getElementById('pdf-files-list');
                const filesList = document.getElementById('files-list');
                const anomalyFilesList = document.getElementById('anomaly-files-list');
                
                if (pdfFilesList) {
                    pdfFilesList.innerHTML = '';
                    pdfFiles.forEach(filename => {
                        const fileItem = this.createFileItem(filename, 'pdf');
                        pdfFilesList.appendChild(fileItem);
                    });
                }
                
                if (filesList) {
                    filesList.innerHTML = '';
                    processedFiles.forEach(filename => {
                        const fileItem = this.createFileItem(filename, 'processed');
                        filesList.appendChild(fileItem);
                    });
                }
                
                if (anomalyFilesList) {
                    anomalyFilesList.innerHTML = '';
                    anomalyFiles.forEach(filename => {
                        const fileItem = this.createFileItem(filename, 'anomaly');
                        anomalyFilesList.appendChild(fileItem);
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                const filesList = document.getElementById('files-list');
                if (filesList) {
                    filesList.innerHTML = '<div class="error-message">Failed to load files</div>';
                }
            });
    }

    // Create file item - extracted from existing script.js
    createFileItem(filename, type) {
        const fileItem = document.createElement('div');
        fileItem.className = 'file-item';
        
        const deleteButton = document.createElement('button');
        deleteButton.className = 'delete-btn';
        deleteButton.textContent = 'Delete';
        deleteButton.addEventListener('click', () => this.deleteFile(filename));

        const downloadButton = document.createElement('button');
        downloadButton.className = 'download-button';
        downloadButton.textContent = 'Download';
        downloadButton.addEventListener('click', () => {
            window.location.href = `/download/${encodeURIComponent(filename)}`;
        });

        const actions = document.createElement('div');
        actions.className = 'file-actions';
        actions.appendChild(downloadButton);
        actions.appendChild(deleteButton);

        const nameSpan = document.createElement('span');
        nameSpan.className = 'file-name';
        nameSpan.textContent = filename;
        
        if (type === 'pdf') {
            nameSpan.style.fontWeight = 'bold';
            nameSpan.style.color = '#2E86AB';
        }

        fileItem.appendChild(nameSpan);
        fileItem.appendChild(actions);
        return fileItem;
    }

    // Delete file - extracted from existing script.js
    deleteFile(filename) {
        if (!confirm(`Are you sure you want to delete ${filename}?`)) {
            return;
        }

        fetch(`/delete/${encodeURIComponent(filename)}`, {
            method: 'DELETE'
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => Promise.reject(err));
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                const fileItems = document.querySelectorAll('.file-item');
                fileItems.forEach(item => {
                    if (item.querySelector('.file-name').textContent === filename) {
                        item.remove();
                    }
                });
                
                this.showMessage('File deleted successfully', 'success');
                setTimeout(() => this.loadFiles(), 500);
            } else {
                throw new Error(data.error || 'Failed to delete file');
            }
        })
        .catch(error => {
            this.showMessage(error.message, 'error');
        });
    }

    // Delete all files - extracted from existing script.js
    deleteAllFiles() {
        if (!confirm('Are you sure you want to delete all files? This action cannot be undone.')) {
            return;
        }

        fetch('/delete-all', {
            method: 'DELETE'
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => Promise.reject(err));
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                const filesList = document.getElementById('files-list');
                if (filesList) {
                    filesList.innerHTML = '';
                }
                this.showMessage('All files deleted successfully', 'success');
                this.loadFiles();
            }
        })
        .catch(error => {
            this.showMessage(`Error: ${error.message || 'Failed to delete files'}`, 'error');
        });
    }

    // Download all files - extracted from existing script.js
    downloadAllFiles() {
        fetch('/files')
            .then(response => response.json())
            .then(data => {
                if (data.files && data.files.length > 0) {
                    window.location.href = '/download-all';
                } else {
                    this.showMessage('No files available to download', 'error');
                }
            })
            .catch(error => {
                this.showMessage(`Error: ${error.message || 'Failed to check files'}`, 'error');
            });
    }

    // Generate PDF report - extracted from existing script.js
    generatePDFReport() {
        fetch('/generate-pdf-report', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showMessage(`PDF report generated: ${data.pdf_filename}`, 'success');
                this.loadFiles();
            } else {
                this.showMessage(`Error: ${data.error}`, 'error');
            }
        })
        .catch(error => {
            this.showMessage(`Error generating PDF: ${error.message}`, 'error');
        });
    }

    // Reset all data - extracted from existing script.js
    resetAllData() {
        if (!confirm('This will delete ALL files and clear the database. This action cannot be undone. Continue?')) {
            return;
        }
        
        fetch('/reset-all-data', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showMessage(`Reset completed: ${data.details.files_deleted} files deleted, database cleared`, 'success');
                this.loadFiles();
            } else {
                this.showMessage(`Reset error: ${data.error}`, 'error');
            }
        })
        .catch(error => {
            this.showMessage(`Reset failed: ${error.message}`, 'error');
        });
    }

    // Show message - extracted from existing script.js
    showMessage(message, type) {
        const messageEl = document.getElementById('delete-message');
        if (messageEl) {
            messageEl.textContent = message;
            messageEl.className = `delete-message ${type}`;
            setTimeout(() => {
                messageEl.textContent = '';
                messageEl.classList.remove(type);
            }, 3000);
        }
    }
}

// Export for both CommonJS and ES6 modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FileManager;
}

// Make available globally
if (typeof window !== 'undefined') {
    window.FileManager = FileManager;
}
