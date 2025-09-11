/**
 * FileUploadManager - A comprehensive file upload and management system
 * Handles drag-drop uploads, queue management, file processing, and validation
 * 
 * Features:
 * - Drag & drop file uploads
 * - Upload queue with progress tracking
 * - File validation and error handling
 * - Integration with backend APIs
 * - Event-driven architecture
 * - Configurable options
 */
class FileUploadManager {
    /**
     * @param {string} uploadZoneSelector - CSS selector for the drop zone element
     * @param {Object} options - Configuration options
     */
    constructor(uploadZoneSelector, options = {}) {
        // Core DOM elements
        this.uploadZone = null;
        this.fileInput = null;
        this.progressBar = null;
        this.uploadQueue = null;
        
        // Configuration
        this.options = {
            uploadEndpoint: '/upload',
            allowedExtensions: ['xlsx', 'csv'],
            maxFileSize: 50 * 1024 * 1024, // 50MB
            autoRemoveCompleted: true,
            autoRemoveDelay: 8000,
            autoRemoveErrorDelay: 5000,
            showValidationDetails: true,
            ...options
        };
        
        // State management
        this.uploadQueue = [];
        this.isInitialized = false;
        
        // Event callbacks
        this.callbacks = {
            onFileAdded: null,
            onUploadStart: null,
            onUploadProgress: null,
            onUploadComplete: null,
            onUploadError: null,
            onValidationError: null,
            onFileRemoved: null
        };
        
        // Store the selector for initialization
        this.uploadZoneSelector = uploadZoneSelector;
        
        // Auto-initialize if DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.init());
        } else {
            this.init();
        }
    }
    
    /**
     * Initialize the file upload manager
     * Sets up DOM elements and event listeners
     */
    init() {
        try {
            this._findDOMElements();
            this._validateDOMElements();
            this._setupEventListeners();
            this._setupDragAndDrop();
            this.isInitialized = true;
            this._log('FileUploadManager initialized successfully');
        } catch (error) {
            this._error('Failed to initialize FileUploadManager:', error);
            throw new Error(`FileUploadManager initialization failed: ${error.message}`);
        }
    }
    
    /**
     * Find and cache DOM elements
     * @private
     */
    _findDOMElements() {
        this.uploadZone = document.querySelector(this.uploadZoneSelector);
        
        if (this.uploadZone) {
            this.fileInput = this.uploadZone.querySelector('#file-input') || 
                           this.uploadZone.querySelector('input[type="file"]');
            this.progressBar = document.querySelector('#progress-bar');
            this.uploadQueueElement = document.querySelector('#upload-queue');
        }
    }
    
    /**
     * Validate that required DOM elements exist
     * @private
     */
    _validateDOMElements() {
        if (!this.uploadZone) {
            throw new Error(`Upload zone not found with selector: ${this.uploadZoneSelector}`);
        }
        
        if (!this.fileInput) {
            throw new Error('File input element not found within upload zone');
        }
        
        if (!this.uploadQueueElement) {
            this._warn('Upload queue element not found - queue items will not be displayed');
        }
    }
    
    /**
     * Set up event listeners for file input and other interactions
     * @private
     */
    _setupEventListeners() {
        // File input change event
        this.fileInput.addEventListener('change', (e) => {
            this.handleFileSelection(e.target.files);
        });
        
        // Prevent form submission on file input
        this.fileInput.addEventListener('click', (e) => {
            e.stopPropagation();
        });
    }
    
    /**
     * Set up drag and drop functionality
     * @private
     */
    _setupDragAndDrop() {
        // Prevent default drag behaviors on document
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            this.uploadZone.addEventListener(eventName, this._preventDefaults.bind(this), false);
            document.body.addEventListener(eventName, this._preventDefaults.bind(this), false);
        });
        
        // Highlight drop zone when item is dragged over it
        ['dragenter', 'dragover'].forEach(eventName => {
            this.uploadZone.addEventListener(eventName, this._highlightDropZone.bind(this), false);
        });
        
        ['dragleave', 'drop'].forEach(eventName => {
            this.uploadZone.addEventListener(eventName, this._unhighlightDropZone.bind(this), false);
        });
        
        // Handle dropped files
        this.uploadZone.addEventListener('drop', this.handleDrop.bind(this), false);
    }
    
    /**
     * Handle drag and drop events
     * @param {DragEvent} event - The drop event
     */
    handleDrop(event) {
        const dt = event.dataTransfer;
        const files = dt.files;
        this.handleFileSelection(files);
    }
    
    /**
     * Handle file selection (from input or drop)
     * @param {FileList} files - Selected files
     */
    handleFileSelection(files) {
        if (!files || files.length === 0) {
            return;
        }
        
        const validFiles = [];
        const invalidFiles = [];
        
        Array.from(files).forEach(file => {
            const validation = this._validateFile(file);
            if (validation.isValid) {
                validFiles.push(file);
            } else {
                invalidFiles.push({ file, errors: validation.errors });
            }
        });
        
        // Show validation errors for invalid files
        invalidFiles.forEach(({ file, errors }) => {
            this.showMessage(`${file.name}: ${errors.join(', ')}`, 'error');
            this._triggerCallback('onValidationError', { file, errors });
        });
        
        // Process valid files
        validFiles.forEach(file => {
            this._addFileToQueue(file);
        });
        
        // Clear file input
        this.fileInput.value = '';
    }
    
    /**
     * Validate a file before upload
     * @param {File} file - File to validate
     * @returns {Object} Validation result
     * @private
     */
    _validateFile(file) {
        const errors = [];
        
        // Check file size
        if (file.size > this.options.maxFileSize) {
            errors.push(`File too large (max ${this._formatFileSize(this.options.maxFileSize)})`);
        }
        
        // Check file extension
        const extension = file.name.split('.').pop().toLowerCase();
        if (!this.options.allowedExtensions.includes(extension)) {
            errors.push(`Invalid file type (allowed: ${this.options.allowedExtensions.join(', ')})`);
        }
        
        return {
            isValid: errors.length === 0,
            errors
        };
    }
    
    /**
     * Add a file to the upload queue and start upload
     * @param {File} file - File to add
     * @private
     */
    _addFileToQueue(file) {
        const queueItem = this.createQueueItem(file);
        this.uploadQueue.push(queueItem);
        
        if (this.uploadQueueElement) {
            this.uploadQueueElement.appendChild(queueItem.element);
        }
        
        this._triggerCallback('onFileAdded', { file, queueItem });
        this.uploadFile(file, queueItem);
    }
    
    /**
     * Create a queue item for tracking upload progress
     * @param {File} file - File for the queue item
     * @returns {Object} Queue item object
     */
    createQueueItem(file) {
        const element = document.createElement('div');
        element.className = 'queue-item';
        element.innerHTML = `
            <div class="file-info">
                <span class="file-name">${this._escapeHtml(file.name)}</span>
                <span class="file-size">${this._formatFileSize(file.size)}</span>
                <span class="file-status">Waiting to upload...</span>
            </div>
            <div class="progress-container">
                <div class="progress-bar" style="width: 100px;">
                    <div class="progress" style="width: 0%"></div>
                </div>
                <button class="cancel-btn" title="Cancel upload">×</button>
            </div>
        `;
        
        const queueItem = {
            id: this._generateId(),
            file,
            element,
            status: 'waiting',
            validationDetails: null,
            startTime: Date.now()
        };
        
        // Add cancel functionality
        const cancelBtn = element.querySelector('.cancel-btn');
        cancelBtn.addEventListener('click', () => {
            this._removeQueueItem(queueItem);
        });
        
        return queueItem;
    }
    
    /**
     * Upload a file to the server
     * @param {File} file - File to upload
     * @param {Object} queueItem - Queue item for tracking
     */
    async uploadFile(file, queueItem) {
        try {
            this.updateQueueItem(queueItem, 'uploading', 'Uploading...');
            this._triggerCallback('onUploadStart', { file, queueItem });
            
            const formData = new FormData();
            formData.append('file', file);
            
            const response = await fetch(this.options.uploadEndpoint, {
                method: 'POST',
                body: formData
            });
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.error || `HTTP ${response.status}: Upload failed`);
            }
            
            const data = await response.json();
            
            this._handleUploadSuccess(queueItem, data);
            this._triggerCallback('onUploadComplete', { file, queueItem, data });
            
        } catch (error) {
            this._handleUploadError(queueItem, error);
            this._triggerCallback('onUploadError', { file, queueItem, error });
        }
    }
    
    /**
     * Handle successful upload response
     * @param {Object} queueItem - Queue item
     * @param {Object} data - Response data
     * @private
     */
    _handleUploadSuccess(queueItem, data) {
        if (data.success) {
            let statusMessage = '✅ Finished uploading!';
            let isError = false;
            
            // Check validation results
            if (data.validation && data.validation.total_errors > 0) {
                statusMessage = `⚠️ Uploaded with ${data.validation.total_errors} validation errors`;
                isError = true;
                
                if (this.options.showValidationDetails) {
                    queueItem.validationDetails = {
                        errors: data.validation.errors || [],
                        warnings: data.validation.warnings || []
                    };
                }
            }
            
            console.log('Setting upload as completed:', statusMessage);
            this.updateQueueItem(queueItem, 'completed', statusMessage, isError);
            
            if (this.options.autoRemoveCompleted) {
                setTimeout(() => {
                    this._removeQueueItem(queueItem);
                }, this.options.autoRemoveDelay);
            }
        } else {
            throw new Error(data.error || 'Upload failed');
        }
    }
    
    /**
     * Handle upload error
     * @param {Object} queueItem - Queue item
     * @param {Error} error - Error object
     * @private
     */
    _handleUploadError(queueItem, error) {
        this._error('Upload failed:', error);
        this.updateQueueItem(queueItem, 'error', error.message || 'Upload failed', true);
        
        setTimeout(() => {
            this._removeQueueItem(queueItem);
        }, this.options.autoRemoveErrorDelay);
    }
    
    /**
     * Update queue item status and appearance
     * @param {Object} queueItem - Queue item to update
     * @param {string} status - New status
     * @param {string} message - Status message
     * @param {boolean} isError - Whether this is an error state
     */
    updateQueueItem(queueItem, status, message = '', isError = false) {
        queueItem.status = status;
        
        const statusEl = queueItem.element.querySelector('.file-status');
        const progressEl = queueItem.element.querySelector('.progress');
        
        if (statusEl) {
            statusEl.textContent = message || status;
        }
        
        // Update visual state
        queueItem.element.classList.remove('uploading', 'completed', 'error');
        
        if (isError) {
            queueItem.element.classList.add('error');
        } else if (status === 'completed') {
            queueItem.element.classList.add('completed');
            if (progressEl) {
                progressEl.style.width = '100%';
            }
        } else if (status === 'uploading') {
            queueItem.element.classList.add('uploading');
        }
        
        this._triggerCallback('onUploadProgress', { queueItem, status, message, isError });
    }
    
    /**
     * Remove item from queue
     * @param {Object} queueItem - Queue item to remove
     * @private
     */
    _removeQueueItem(queueItem) {
        const index = this.uploadQueue.findIndex(item => item.id === queueItem.id);
        if (index > -1) {
            this.uploadQueue.splice(index, 1);
        }
        
        if (queueItem.element && queueItem.element.parentNode) {
            queueItem.element.remove();
        }
        
        this._triggerCallback('onFileRemoved', { queueItem });
    }
    
    /**
     * Show a message to the user
     * @param {string} message - Message to show
     * @param {string} type - Message type ('success', 'error', 'info')
     */
    showMessage(message, type = 'info') {
        // Try to find a message container
        let messageEl = document.getElementById('delete-message') || 
                       document.querySelector('.message-container') ||
                       document.querySelector('.upload-message');
        
        if (!messageEl) {
            // Create a temporary message element
            messageEl = document.createElement('div');
            messageEl.className = 'upload-message';
            messageEl.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 12px 20px;
                border-radius: 4px;
                z-index: 10000;
                font-weight: 500;
                min-width: 250px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            `;
            document.body.appendChild(messageEl);
        }
        
        messageEl.textContent = message;
        messageEl.className = `upload-message ${type}`;
        
        // Auto-remove message
        setTimeout(() => {
            if (messageEl.parentNode) {
                messageEl.remove();
            }
        }, 5000);
    }
    
    /**
     * Set event callback
     * @param {string} eventName - Event name
     * @param {Function} callback - Callback function
     */
    on(eventName, callback) {
        if (this.callbacks.hasOwnProperty(`on${eventName.charAt(0).toUpperCase() + eventName.slice(1)}`)) {
            this.callbacks[`on${eventName.charAt(0).toUpperCase() + eventName.slice(1)}`] = callback;
        } else {
            this._warn(`Unknown event: ${eventName}`);
        }
    }
    
    /**
     * Get current queue status
     * @returns {Object} Queue statistics
     */
    getQueueStatus() {
        const statusCounts = this.uploadQueue.reduce((acc, item) => {
            acc[item.status] = (acc[item.status] || 0) + 1;
            return acc;
        }, {});
        
        return {
            total: this.uploadQueue.length,
            waiting: statusCounts.waiting || 0,
            uploading: statusCounts.uploading || 0,
            completed: statusCounts.completed || 0,
            error: statusCounts.error || 0
        };
    }
    
    /**
     * Clear completed items from queue
     */
    clearCompleted() {
        const completedItems = this.uploadQueue.filter(item => item.status === 'completed');
        completedItems.forEach(item => this._removeQueueItem(item));
    }
    
    /**
     * Destroy the upload manager and clean up
     */
    destroy() {
        // Remove event listeners
        if (this.uploadZone) {
            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                this.uploadZone.removeEventListener(eventName, this._preventDefaults);
            });
        }
        
        // Clear queue
        this.uploadQueue.forEach(item => this._removeQueueItem(item));
        
        // Reset state
        this.isInitialized = false;
        this.uploadQueue = [];
        this.callbacks = {};
        
        this._log('FileUploadManager destroyed');
    }
    
    // Utility methods
    
    /**
     * Prevent default event behavior
     * @param {Event} e - Event object
     * @private
     */
    _preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    /**
     * Highlight drop zone
     * @private
     */
    _highlightDropZone() {
        this.uploadZone.classList.add('drag-over');
    }
    
    /**
     * Remove drop zone highlight
     * @private
     */
    _unhighlightDropZone() {
        this.uploadZone.classList.remove('drag-over');
    }
    
    /**
     * Format file size for display
     * @param {number} bytes - Size in bytes
     * @returns {string} Formatted size
     * @private
     */
    _formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    /**
     * Escape HTML to prevent XSS
     * @param {string} text - Text to escape
     * @returns {string} Escaped text
     * @private
     */
    _escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    /**
     * Generate unique ID
     * @returns {string} Unique ID
     * @private
     */
    _generateId() {
        return 'upload_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    /**
     * Trigger callback if it exists
     * @param {string} callbackName - Callback name
     * @param {*} data - Data to pass to callback
     * @private
     */
    _triggerCallback(callbackName, data) {
        if (typeof this.callbacks[callbackName] === 'function') {
            try {
                this.callbacks[callbackName](data);
            } catch (error) {
                this._error(`Error in callback ${callbackName}:`, error);
            }
        }
    }
    
    /**
     * Log info message
     * @param {...*} args - Arguments to log
     * @private
     */
    _log(...args) {
        console.log('[FileUploadManager]', ...args);
    }
    
    /**
     * Log warning message
     * @param {...*} args - Arguments to log
     * @private
     */
    _warn(...args) {
        console.warn('[FileUploadManager]', ...args);
    }
    
    /**
     * Log error message
     * @param {...*} args - Arguments to log
     * @private
     */
    _error(...args) {
        console.error('[FileUploadManager]', ...args);
    }
}

// Export for both CommonJS and ES6 modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FileUploadManager;
}

// Make available globally
if (typeof window !== 'undefined') {
    window.FileUploadManager = FileUploadManager;
}
