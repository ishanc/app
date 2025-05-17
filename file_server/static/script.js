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
            updateQueueItem(queueItem, 'completed', 'File processed successfully!');
            
            // Update the file list after a small delay to ensure the server has completed processing
            setTimeout(() => loadFiles(), 500);
            
            // Remove the queue item after showing success for a moment
            setTimeout(() => {
                queueItem.remove();
            }, 3000);
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

    function loadFiles() {
        fetch('/files')
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to fetch files');
                }
                return response.json();
            })
            .then(data => {
                filesList.innerHTML = '';
                data.files.forEach(filename => {
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

                    fileItem.appendChild(nameSpan);
                    fileItem.appendChild(actions);
                    filesList.appendChild(fileItem);
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
                filesList.innerHTML = '<div class="error-message">Failed to load files</div>';
            });
    }

});
