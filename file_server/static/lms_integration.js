/**
 * Simple LMS Integration for FileUploadManager
 * Uses existing backend endpoints without modifications
 */

let lmsUploadManager = null;

function initializeLMSUploadManager() {
    // Properly cleanup old instance before creating new one
    if (lmsUploadManager) {
        console.log('Destroying existing FileUploadManager to prevent event listener stacking');
        lmsUploadManager./* The `destroy` method in the code snippet is used to clean up and remove the
        existing instance of the `FileUploadManager` before creating a new one.
        This is important to prevent event listener stacking and potential memory
        leaks. */
        destroy();
        lmsUploadManager = null;
    }
    
    try {
        lmsUploadManager = new FileUploadManager('#drop-zone', {
            uploadEndpoint: '/upload',  // Use existing endpoint
            allowedExtensions: ['xlsx', 'csv'],
            maxFileSize: 50 * 1024 * 1024,
            autoRemoveCompleted: false,  // Keep items visible to show success
            autoRemoveDelay: 10000       // Remove after 10 seconds
        });

        // Wire to existing loadFiles function
        lmsUploadManager.on('uploadComplete', () => {
            if (typeof loadFiles === 'function') {
                setTimeout(() => loadFiles(), 500);
            }
        });
        
        console.log('✅ FileUploadManager initialized');
        return true;
        
    } catch (error) {
        console.error('❌ Failed to initialize FileUploadManager:', error);
        return false;
    }
}

// Simple global object
window.LMSUploadIntegration = {
    initialize: initializeLMSUploadManager,
    getManager: () => lmsUploadManager
};
