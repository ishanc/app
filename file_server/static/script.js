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
                // Download each file individually since /download-all endpoint doesn't exist
                data.files.forEach((filename, index) => {
                    setTimeout(() => {
                        window.location.href = `/download/${encodeURIComponent(filename)}`;
                    }, index * 500); // Stagger downloads to avoid browser blocking
                });
                
                const messageEl = document.getElementById('delete-message');
                messageEl.textContent = `Downloading ${data.files.length} files...`;
                messageEl.classList.add('success');
                setTimeout(() => {
                    messageEl.textContent = '';
                    messageEl.classList.remove('success');
                }, 3000);
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

// Handle Download Anomaly Reports functionality
function downloadAnomalyReports() {
    fetch('/files')
        .then(response => response.json())
        .then(data => {
            // Filter for anomaly reports only
            const anomalyFiles = data.files.filter(f => f.startsWith('anomaly_report_') && f.endsWith('.csv'));
            
            if (anomalyFiles.length > 0) {
                // Download each anomaly file individually
                anomalyFiles.forEach((filename, index) => {
                    setTimeout(() => {
                        window.location.href = `/download/${encodeURIComponent(filename)}`;
                    }, index * 500); // Stagger downloads to avoid browser blocking
                });
                
                const messageEl = document.getElementById('delete-message');
                messageEl.textContent = `Downloading ${anomalyFiles.length} anomaly reports...`;
                messageEl.classList.add('success');
                setTimeout(() => {
                    messageEl.textContent = '';
                    messageEl.classList.remove('success');
                }, 3000);
            } else {
                const messageEl = document.getElementById('delete-message');
                messageEl.textContent = 'No anomaly reports available to download';
                messageEl.classList.add('error');
                setTimeout(() => {
                    messageEl.textContent = '';
                    messageEl.classList.remove('error');
                }, 3000);
            }
        })
        .catch(error => {
            const messageEl = document.getElementById('delete-message');
            messageEl.textContent = `Error: ${error.message || 'Failed to check anomaly files'}`;
            messageEl.classList.add('error');
            setTimeout(() => {
                messageEl.textContent = '';
                messageEl.classList.remove('error');
            }, 3000);
        });
}

// Make functions globally accessible
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
            // COMMENTED OUT: Auto PDF file display
            // Reason: PDFs should only show when user clicks "Generate PDF Report" button
            // const pdfFiles = data.files.filter(f => f.startsWith('data_quality_report') && f.endsWith('.pdf'));
            const processedFiles = data.files.filter(f => f.startsWith('processed_') && f.endsWith('.csv'));
            const anomalyFiles = data.files.filter(f => f.startsWith('anomaly_report_') && f.endsWith('.csv'));
            
            // COMMENTED OUT: Auto PDF file display  
            // Reason: PDFs should only populate when user explicitly requests them
            // // Display PDF files
            // const pdfFilesList = document.getElementById('pdf-files-list');
            // pdfFilesList.innerHTML = '';
            // pdfFiles.forEach(filename => {
            //     const fileItem = createFileItem(filename, 'pdf');
            //     pdfFilesList.appendChild(fileItem);
            // });
            
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

// Make deleteFile and downloadAnomalyReports functions globally accessible
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

// Make downloadAnomalyReports function globally accessible
window.downloadAnomalyReports = downloadAnomalyReports;

document.addEventListener('DOMContentLoaded', () => {
    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');
    const progressBar = document.getElementById('progress-bar');
    const progress = document.getElementById('progress');
    const filesList = document.getElementById('files-list');
    const deleteAllBtn = document.getElementById('deleteAllBtn');
    const downloadAllBtn = document.getElementById('downloadAllBtn');
    const generatePDFBtn = document.getElementById('generatePDFBtn');
    const resetAllBtn = document.getElementById('resetAllBtn');

    // Add event listeners for bulk action buttons
    if (deleteAllBtn) {
        deleteAllBtn.addEventListener('click', deleteAllFiles);
    }
    if (downloadAllBtn) {
        downloadAllBtn.addEventListener('click', downloadAllFiles);
    }
    if (generatePDFBtn) {
        generatePDFBtn.addEventListener('click', generatePDFReport);
    }
    if (resetAllBtn) {
        resetAllBtn.addEventListener('click', resetAllData);
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
    //dropZone.addEventListener('drop', handleDrop, false);
    
    // Handle selected files
    //fileInput.addEventListener('change', (e) => {
       // handleFiles(e.target.files);
    //});

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
        Array.from(files).forEach(file => {
            const queueItem = createQueueItem(file);
            uploadQueue.appendChild(queueItem);
            uploadFile(file, queueItem);
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

    function uploadFile(file, queueItem) {
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
                
                // Refresh the file list to show new processed files
                setTimeout(() => loadFiles(), 500);
                
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

// Generate PDF Report - now gets latest existing or generates new one - there was an existing function we deleted it for having filemanager do it. 
// REMOVED: generatePDFReport function
// Reason: Using FileManager.js implementation via file_manager_integration.js
// The global generatePDFReport function is now handled by FileManager class

// Reset All Data
function resetAllData() {
    console.log('🔍 Reset button clicked!'); // DEBUG
    
    if (!confirm('This will delete ALL files and clear the database. This action cannot be undone. Continue?')) {
        console.log('❌ User cancelled reset'); // DEBUG
        return;
    }
    
    console.log('🚀 Starting reset request...'); // DEBUG
    
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

// Enhanced dashboard metrics functionality - matches script_dashboard.js

// Helper function to safely update dashboard elements
function setText(id, value) {
    const el = document.getElementById(id);
    if (!el) {
        console.warn('Missing dashboard element:', id);
        return;
    }
    el.textContent = (typeof value === 'number') ? value.toLocaleString() : String(value);
    el.title = `Last updated: ${new Date().toLocaleTimeString()}`;
}

function updateDashboardMetrics() {
    console.log('DEBUG: Fetching metrics from /api/metrics');
    fetch('/api/metrics')
        .then(r => {
            if (!r.ok) throw new Error('Failed to fetch dashboard metrics');
            return r.json();
        })
        .then(data => {
            console.log('DEBUG: Metrics response:', data);
            const m = (data && data.metrics) ? data.metrics : {};
            setText('total-objects-processed', m.total_records_processed ?? '0');
            setText('total-records-with-anomalies', m.total_records_with_anomalies ?? '0');
            setText('total-clean-records', m.total_clean_records ?? '0');
        })
        .catch(err => {
            console.error('metrics error:', err);
            ['total-objects-processed','total-records-with-anomalies','total-clean-records']
                .forEach(id => setText(id, 'Error'));
        });
}

// Reset dashboard metrics function
function resetDashboardMetrics() {
    const elements = ['total-objects-processed', 'total-records-with-anomalies', 'total-clean-records'];
    elements.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.textContent = '0';
        }
    });
}

// Update metrics on page load and periodically
document.addEventListener('DOMContentLoaded', () => {
    updateDashboardMetrics();
    
    // Update every 5 seconds when dashboard is visible
    setInterval(() => {
        const dashboardSection = document.getElementById('dashboard');
        if (dashboardSection && !dashboardSection.classList.contains('hidden')) {
            updateDashboardMetrics();
        }
    }, 5000);
});

// Event listeners are already added in the main DOMContentLoaded listener above

// File Upload Tracking Functionality
class FileUploadTracker {
    constructor() {
        this.requiredFiles = [
            'Prerequisites_Provider',
            'Prerequisites_QuestionBanks', 
            'Core_Domain',
            'Activity_ILTSessions',
            'Activity_ILTCourse',
            'Activity_QuickAssessment',
            'Activity_ILTClass',
            'Core_Audience',
            'Activity_Document',
            'Prerequisites_Subject',
            'Core_Organization',
            'Prerequisites_Instructor',
            'Prerequisites_Question',
            'Core_Jobs',
            'Activity_Online_Course',
            'Activity_Curriculum',
            'Core_Employee',
            'Transcript_ILT_Class',
            'Prerequisites_Facility',
            'Transcript_Curriculum',
            'Transcript_Document',
            'Transcript_Online_Course',
            'Transcript_QuickAssessment'
        ];
        
        this.uploadedFiles = new Set();
        this.initializeTable();
        this.loadExistingFiles(); // One-time load on initialization
        this.setupUploadListener(); // Hook into upload events
    }
    
    // Hook into upload events for immediate updates
    setupUploadListener() {
        // Hook into FileUploadManager when available
        const hookManager = () => {
            if (window.lmsUploadManager) {
                window.lmsUploadManager.on('uploadComplete', (data) => {
                    const filename = data?.file?.name || data?.filename;
                    console.log('FileUploadTracker: Upload completed:', filename);
                    if (filename) {
                        this.checkAndUpdateFile(filename);
                    }
                });
                console.log('FileUploadTracker: Hooked into upload manager');
                return true;
            }
            return false;
        };
        
        // Try immediate hook, or wait for manager to be available
        if (!hookManager()) {
            const checkInterval = setInterval(() => {
                if (hookManager()) {
                    clearInterval(checkInterval);
                }
            }, 500);
            setTimeout(() => clearInterval(checkInterval), 5000); // Stop after 5 seconds
        }
    }
    
    // Efficient local matching - no API calls
    checkAndUpdateFile(filename) {
        if (!filename) return false;
        
        const baseFilename = filename.replace(/\.(xlsx|csv)$/i, '');
        
        const matchedIndex = this.requiredFiles.findIndex(requiredFile => {
            // Direct match
            if (baseFilename === requiredFile) return true;
            
            // Normalized match (remove spaces, underscores, hyphens, case insensitive)
            const normalizedBase = baseFilename.replace(/[-_\s]/g, '').toLowerCase();
            const normalizedRequired = requiredFile.replace(/[-_\s]/g, '').toLowerCase();
            return normalizedBase === normalizedRequired;
        });
        
        if (matchedIndex !== -1) {
            const requiredFile = this.requiredFiles[matchedIndex];
            
            // Only update if this is a new file
            if (!this.uploadedFiles.has(requiredFile)) {
                this.uploadedFiles.add(requiredFile);
                this.updateFileStatus(matchedIndex, true);
                this.updateSummary();
                
                console.log(`FileUploadTracker: ✅ Matched "${filename}" → "${requiredFile}" (${this.uploadedFiles.size}/${this.requiredFiles.length})`);
                return true;
            }
        }
        
        return false;
    }
    
    // One-time load of existing files (only called on page load)
    async loadExistingFiles() {
        try {
            const response = await fetch('/files');
            if (response.ok) {
                const data = await response.json();
                const uploadedFilenames = [];
                
                if (data.uploads && Array.isArray(data.uploads)) {
                    data.uploads.forEach(file => {
                        const filename = file.name || file.filename || file;
                        uploadedFilenames.push(filename);
                    });
                }
                
                console.log('FileUploadTracker: Loading existing files:', uploadedFilenames);
                
                // Process existing files
                uploadedFilenames.forEach(filename => {
                    this.checkAndUpdateFile(filename);
                });
            }
        } catch (error) {
            console.error('FileUploadTracker: Error loading existing files:', error);
        }
    }
    
    initializeTable() {
        const tbody = document.getElementById('file-tracking-tbody');
        if (!tbody) return;
        
        tbody.innerHTML = '';
        
        this.requiredFiles.forEach((fileName, index) => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td style="font-weight: 500;">${fileName}.xlsx/.csv</td>
                <td>
                    <div class="file-status not-uploaded" id="status-${index}">
                        <svg class="status-icon" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                        </svg>
                        Not Uploaded
                    </div>
                </td>
            `;
            tbody.appendChild(row);
        });
        
        this.updateSummary();
    }
    
    updateFileStatus(index, isUploaded) {
        const statusElement = document.getElementById(`status-${index}`);
        if (!statusElement) return;
        
        if (isUploaded) {
            statusElement.className = 'file-status uploaded';
            statusElement.innerHTML = `
                <svg class="status-icon" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                Uploaded
            `;
        }
    }
    
    updateSummary() {
        const uploadedCount = this.uploadedFiles.size;
        const totalFiles = this.requiredFiles.length;
        
        // Update counter
        const countElement = document.getElementById('files-uploaded-count');
        const summaryElement = document.getElementById('upload-progress-summary');
        
        if (countElement) {
            countElement.textContent = uploadedCount;
        }
        
        if (summaryElement) {
            if (uploadedCount === totalFiles) {
                summaryElement.classList.add('complete');
            } else {
                summaryElement.classList.remove('complete');
            }
        }
        
        // Update completion status
        this.updateCompletionStatus(uploadedCount, totalFiles);
    }
    
    updateCompletionStatus(uploadedCount, totalFiles) {
        const statusDiv = document.getElementById('completion-status');
        const messageDiv = document.getElementById('completion-message');
        
        if (!statusDiv || !messageDiv) return;
        
        if (uploadedCount === totalFiles) {
            statusDiv.className = 'completion-success';
            statusDiv.style.display = 'block';
            messageDiv.innerHTML = `
                <strong>✅ All Required Files Uploaded!</strong><br>
                You can now generate the complete PDF report with full cross-file relationship analysis.
            `;
        } else if (uploadedCount > 0) {
            statusDiv.className = 'completion-incomplete';
            statusDiv.style.display = 'block';
            messageDiv.innerHTML = `
                <strong>⚠️ ${totalFiles - uploadedCount} files still needed</strong><br>
                Upload all required files to enable complete cross-file analysis in the PDF report.
            `;
        } else {
            statusDiv.style.display = 'none';
        }
    }
}

// Initialize tracker when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('file-tracking-table')) {
        fileUploadTracker = new FileUploadTracker();
        window.fileUploadTracker = fileUploadTracker;
        console.log('✅ FileUploadTracker initialized with event-based updates');
    }
});