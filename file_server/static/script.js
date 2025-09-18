// Handle Delete All functionality
function deleteAllFiles() {
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
            // Clear the files list immediately
            const filesList = document.getElementById('files-list');
            if (filesList) {
                filesList.innerHTML = '';
            }

            const messageEl = document.getElementById('delete-message');
            messageEl.textContent = 'All files deleted successfully';
            messageEl.classList.add('success');
            setTimeout(() => {
                messageEl.textContent = '';
                messageEl.classList.remove('success');
            }, 3000);
            
            // Reload the file list to ensure sync with server
            loadFiles();
        }
    })
    .catch(error => {
        const messageEl = document.getElementById('delete-message');
        messageEl.textContent = `Error: ${error.message || 'Failed to delete files'}`;
        messageEl.classList.add('error');
        setTimeout(() => {
            messageEl.textContent = '';
            messageEl.classList.remove('error');
        }, 3000);
    });
}

// Handle Download All functionality
function downloadAllFiles() {
    fetch('/files')
        .then(response => response.json())
        .then(data => {
            if (data.files && data.files.length > 0) {
                // Trigger the download
                window.location.href = '/download-all';
            } else {
                const messageEl = document.getElementById('delete-message');
                messageEl.textContent = 'No files available to download';
                messageEl.classList.add('error');
                setTimeout(() => {
                    messageEl.textContent = '';
                    messageEl.classList.remove('error');
                }, 3000);
            }
        })
        .catch(error => {
            const messageEl = document.getElementById('delete-message');
            messageEl.textContent = `Error: ${error.message || 'Failed to check files'}`;
            messageEl.classList.add('error');
            setTimeout(() => {
                messageEl.textContent = '';
                messageEl.classList.remove('error');
            }, 3000);
        });
}

// Make loadFiles function globally accessible
window.loadFiles = function() {
    fetch('/files')
        .then(response => {
            if (!response.ok) {
                throw new Error('Failed to fetch files');
            }
            return response.json();
        })
        .then(data => {
            // Categorize files
            const pdfFiles = data.files.filter(f => f.startsWith('data_quality_report') && f.endsWith('.pdf'));
            const processedFiles = data.files.filter(f => f.startsWith('processed_') && f.endsWith('.csv'));
            const anomalyFiles = data.files.filter(f => f.startsWith('anomaly_report_') && f.endsWith('.csv'));
            
            // Display PDF files
            const pdfFilesList = document.getElementById('pdf-files-list');
            pdfFilesList.innerHTML = '';
            pdfFiles.forEach(filename => {
                const fileItem = createFileItem(filename, 'pdf');
                pdfFilesList.appendChild(fileItem);
            });
            
            // Display processed files
            const filesList = document.getElementById('files-list');
            filesList.innerHTML = '';
            processedFiles.forEach(filename => {
                const fileItem = createFileItem(filename, 'processed');
                filesList.appendChild(fileItem);
            });
            
            // Display anomaly files
            const anomalyFilesList = document.getElementById('anomaly-files-list');
            anomalyFilesList.innerHTML = '';
            anomalyFiles.forEach(filename => {
                const fileItem = createFileItem(filename, 'anomaly');
                anomalyFilesList.appendChild(fileItem);
            });
            
            // Add the delete message container if it doesn't exist
            if (!document.getElementById('delete-message')) {
                const messageContainer = document.createElement('div');
                messageContainer.id = 'delete-message';
                messageContainer.className = 'delete-message';
                filesList.parentNode.appendChild(messageContainer);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            const filesList = document.getElementById('files-list');
            filesList.innerHTML = '<div class="error-message">Failed to load files</div>';
        });
};

// Make deleteFile function globally accessible
window.deleteFile = function(filename) {
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
            // Remove the file item from UI immediately
            const fileItems = document.querySelectorAll('.file-item');
            fileItems.forEach(item => {
                if (item.querySelector('.file-name').textContent === filename) {
                    item.remove();
                }
            });
            
            const messageEl = document.getElementById('delete-message');
            messageEl.textContent = 'File deleted successfully';
            messageEl.classList.add('success');
            setTimeout(() => {
                messageEl.textContent = '';
                messageEl.classList.remove('success');
            }, 3000);
            
            // Reload the file list to ensure sync with server
            setTimeout(() => loadFiles(), 500);
        } else {
            throw new Error(data.error || 'Failed to delete file');
        }
    })
    .catch(error => {
        const messageEl = document.getElementById('delete-message');
        messageEl.textContent = error.message;
        messageEl.classList.add('error');
        setTimeout(() => {
            messageEl.textContent = '';
            messageEl.classList.remove('error');
        }, 3000);
    });
};

document.addEventListener('DOMContentLoaded', () => {
    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');
    const progressBar = document.getElementById('progress-bar');
    const progress = document.getElementById('progress');
    const filesList = document.getElementById('files-list');
    const deleteAllBtn = document.getElementById('deleteAllBtn');
    const downloadAllBtn = document.getElementById('downloadAllBtn');

    // Add event listeners for bulk action buttons
    if (deleteAllBtn) {
        deleteAllBtn.addEventListener('click', deleteAllFiles);
    }
    if (downloadAllBtn) {
        downloadAllBtn.addEventListener('click', downloadAllFiles);
    }

    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
        document.body.addEventListener(eventName, preventDefaults, false);
    });

    // Highlight drop zone when item is dragged over it
    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, highlight, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, unhighlight, false);
    });

    // Handle dropped files
    dropZone.addEventListener('drop', handleDrop, false);
    
    // Handle selected files
    fileInput.addEventListener('change', (e) => {
        handleFiles(e.target.files);
    });

    // Initialize files list
    loadFiles();

    function preventDefaults (e) {
        e.preventDefault();
        e.stopPropagation();
    }

    function highlight(e) {
        dropZone.classList.add('drag-over');
    }

    function unhighlight(e) {
        dropZone.classList.remove('drag-over');
    }

    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles(files);
    }

    function handleFiles(files) {
        const uploadQueue = document.getElementById('upload-queue');
        
        // Determine which section we're in
        const analyserUpload = !document.querySelector('#transformation-dashboard').classList.contains('hidden');
        const source = analyserUpload ? 'analyser' : 'transformer';
        
        Array.from(files).forEach(file => {
            const queueItem = createQueueItem(file);
            uploadQueue.appendChild(queueItem);
            uploadFile(file, queueItem, source);
        });
    }

    function createQueueItem(file) {
        const queueItem = document.createElement('div');
        queueItem.className = 'queue-item';
        queueItem.innerHTML = `
            <div class="file-info">
                <span class="file-name">${file.name}</span>
                <span class="file-status">Waiting to upload...</span>
            </div>
            <div class="progress-bar" style="width: 100px;">
                <div class="progress" style="width: 0%"></div>
            </div>
        `;
        return queueItem;
    }

    function updateQueueItem(queueItem, status, message = '', isError = false) {
        const statusEl = queueItem.querySelector('.file-status');
        const progressEl = queueItem.querySelector('.progress');
        
        statusEl.textContent = message || status;
        if (isError) {
            queueItem.classList.add('error');
        } else if (status === 'completed') {
            queueItem.classList.add('completed');
            progressEl.style.width = '100%';
        }
    }

    function uploadFile(file, queueItem, source) {
        const formData = new FormData();
        formData.append('file', file);
        
        updateQueueItem(queueItem, 'uploading', 'Uploading...');

        fetch('/upload', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => Promise.reject(new Error(err.error || 'Upload failed')));
            }
            return response.json();
        })
        .then(data => {
            // Check if processing was successful
            if (data.success) {
                // Check validation results
                if (data.validation) {
                    const validation = data.validation;
                    let statusMessage = 'File processed successfully!';
                    let isError = false;
                    
                    if (validation.total_errors > 0) {
                        statusMessage = `Processed with ${validation.total_errors} validation errors`;
                        isError = true;
                    }
                    
                    updateQueueItem(queueItem, 'completed', statusMessage, isError);
                    
                    // Add validation details to queue item (only errors, not warnings)
                    if (validation.total_errors > 0) {
                        const validationDetails = {
                            errors: validation.errors || [],
                            warnings: []
                        };
                        queueItem.validationDetails = validationDetails;
                    }
                } else {
                    updateQueueItem(queueItem, 'completed', 'File processed successfully!');
                }
                
                // Refresh the file list to show new processed files and update metrics
                setTimeout(() => {
                    loadFiles();
                    updateDashboardMetrics(source);
                }, 500);
                
            } else {
                updateQueueItem(queueItem, 'error', `Error: ${data.error}`, true);
            }
            
            // Remove the queue item after showing success for a moment
            setTimeout(() => {
                queueItem.remove();
            }, 8000);
        })
        .catch(error => {
            console.error('Error:', error);
            updateQueueItem(queueItem, 'error', error.message || 'Upload failed', true);
            
            // Remove failed upload from queue after a delay
            setTimeout(() => {
                queueItem.remove();
            }, 5000);
        });
    }

});

// Create file item with type-specific styling
function createFileItem(filename, type) {
    const fileItem = document.createElement('div');
    fileItem.className = 'file-item';
    
    const deleteButton = document.createElement('button');
    deleteButton.className = 'delete-btn';
    deleteButton.textContent = 'Delete';
    deleteButton.addEventListener('click', () => deleteFile(filename));

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
    
    // Add type-specific styling
    if (type === 'pdf') {
        nameSpan.style.fontWeight = 'bold';
        nameSpan.style.color = '#2E86AB';
    }

    fileItem.appendChild(nameSpan);
    fileItem.appendChild(actions);
    return fileItem;
}

// Generate PDF Report
function generatePDFReport() {
    fetch('/generate-pdf-report', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        const messageEl = document.getElementById('delete-message');
        if (data.success) {
            messageEl.textContent = `PDF report generated: ${data.pdf_filename}`;
            messageEl.classList.add('success');
            loadFiles(); // Refresh to show new PDF
        } else {
            messageEl.textContent = `Error: ${data.error}`;
            messageEl.classList.add('error');
        }
        setTimeout(() => {
            messageEl.textContent = '';
            messageEl.classList.remove('success', 'error');
        }, 5000);
    })
    .catch(error => {
        const messageEl = document.getElementById('delete-message');
        messageEl.textContent = `Error generating PDF: ${error.message}`;
        messageEl.classList.add('error');
        setTimeout(() => {
            messageEl.textContent = '';
            messageEl.classList.remove('error');
        }, 5000);
    });
}

// Reset All Data
function resetAllData() {
    if (!confirm('This will delete ALL files and clear the database. This action cannot be undone. Continue?')) {
        return;
    }
    
    fetch('/reset-all-data', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        const messageEl = document.getElementById('delete-message');
        if (data.success) {
            messageEl.textContent = `Reset completed: ${data.details.files_deleted} files deleted, database cleared`;
            messageEl.classList.add('success');
            loadFiles(); // Refresh all file lists
        } else {
            messageEl.textContent = `Reset error: ${data.error}`;
            messageEl.classList.add('error');
        }
        setTimeout(() => {
            messageEl.textContent = '';
            messageEl.classList.remove('success', 'error');
        }, 5000);
    })
    .catch(error => {
        const messageEl = document.getElementById('delete-message');
        messageEl.textContent = `Reset failed: ${error.message}`;
        messageEl.classList.add('error');
        setTimeout(() => {
            messageEl.textContent = '';
            messageEl.classList.remove('error');
        }, 5000);
    });
}

// [MODIFIED: 2025-09-16] Original section handling was simpler without dashboard integration
/*
// Basic section visibility handling
window.showSection = function(sectionId) {
    // Simply toggle visibility
    document.querySelectorAll('.section').forEach(s => s.style.display = 'none');
    const section = document.getElementById(sectionId);
    if (section) section.style.display = 'block';
};
*/

// Enhanced section visibility handling with proper class management
window.showSection = function(sectionId) {
    // Hide all sections first
    const sections = document.querySelectorAll('.section');
    sections.forEach(section => section.classList.add('hidden'));
    
    // Show the requested section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.remove('hidden');
    }
};

// Add event listeners
document.addEventListener('DOMContentLoaded', function() {
    const generatePDFBtn = document.getElementById('generatePDFBtn');
    const resetAllBtn = document.getElementById('resetAllBtn');
    
    if (generatePDFBtn) {
        generatePDFBtn.addEventListener('click', generatePDFReport);
    }
    if (resetAllBtn) {
        resetAllBtn.addEventListener('click', resetAllData);
    }
    
    // Set up navigation event listeners
    const navLinks = document.querySelectorAll('[data-section]');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const sectionId = link.getAttribute('data-section');
            showSection(sectionId);
        });
    });
    
    // [MODIFIED: 2025-09-16] Original records count update was basic without error handling
    /*
    // Basic records count update
    function updateRecordsProcessed() {
        fetch('/api/records_processed')
            .then(response => response.json())
            .then(data => {
                const el = document.getElementById('records-processed');
                if (el) el.textContent = data.total;
            });
    }
    */

    // Enhanced dashboard record count with error handling and auto-refresh
    let recordsUpdateInterval;
    
    function updateRecordsProcessed() {
        fetch('/api/records_processed')
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to fetch records count');
                }
                return response.json();
            })
            .then(data => {
                const el = document.getElementById('records-processed');
                if (el) {
                    el.textContent = data.total.toLocaleString(); // Format number with commas
                    el.title = `Last updated: ${new Date().toLocaleTimeString()}`; // Show last update time on hover
                }
            })
            .catch(error => {
                console.error('Error updating records count:', error);
                const el = document.getElementById('records-processed');
                if (el) {
                    el.textContent = 'Error';
                    el.title = error.message;
                }
            });
    }

    // Enhanced section visibility handling with records count update
    const origShowSection = window.showSection;
    window.showSection = function(sectionId) {
        origShowSection(sectionId);
        
        // Clear any existing update interval
        if (recordsUpdateInterval) {
            clearInterval(recordsUpdateInterval);
            recordsUpdateInterval = null;
        }
        
        // If showing dashboard, update records and start auto-refresh
        if (sectionId === 'dashboard') {
            updateRecordsProcessed();
            // Update every 30 seconds while dashboard is visible
            recordsUpdateInterval = setInterval(updateRecordsProcessed, 30000);
        }
    };

    // If dashboard is visible on load, update immediately
    if (document.getElementById('dashboard') && !document.getElementById('dashboard').classList.contains('hidden')) {
        updateRecordsProcessed();
    }
});
