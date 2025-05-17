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
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                throw new Error(data.error);
            }
            updateQueueItem(queueItem, 'completed', 'File processed successfully!');
            loadFiles();
        })
        .catch(error => {
            console.error('Error:', error);
            updateQueueItem(queueItem, 'error', error.message || 'Upload failed', true);
        });
    }

    function loadFiles() {
        fetch('/files')
            .then(response => response.json())
            .then(data => {
                filesList.innerHTML = '';
                data.files.forEach(filename => {
                    const fileItem = document.createElement('div');
                    fileItem.className = 'file-item';
                    fileItem.innerHTML = `
                        <span>${filename}</span>
                        <button class="download-button" onclick="window.location.href='/download/${filename}'">
                            Download
                        </button>
                    `;
                    filesList.appendChild(fileItem);
                });
            })
            .catch(error => console.error('Error:', error));
    }
});
