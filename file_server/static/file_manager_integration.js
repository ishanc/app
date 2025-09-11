/**
 * Simple FileManager Integration
 */

let fileManager = null;

function initializeFileManager() {
    try {
        fileManager = new FileManager();
        console.log('✅ FileManager initialized');
        return true;
    } catch (error) {
        console.error('❌ Failed to initialize FileManager:', error);
        return false;
    }
}

/**
 * Maintain backward compatibility with existing global functions
 * These functions are called by existing HTML and other scripts
 */

// Replace global loadFiles function with FileManager method
window.loadFiles = function() {
    if (fileManager) {
        return fileManager.loadFiles();
    } else {
        console.error('FileManager not initialized');
    }
};

// Replace global deleteFile function
window.deleteFile = function(filename) {
    if (fileManager) {
        return fileManager.deleteFile(filename);
    } else {
        console.error('FileManager not initialized');
    }
};

// Replace global deleteAllFiles function
window.deleteAllFiles = function() {
    if (fileManager) {
        return fileManager.deleteAllFiles();
    } else {
        console.error('FileManager not initialized');
    }
};

// Replace global downloadAllFiles function
window.downloadAllFiles = function() {
    if (fileManager) {
        return fileManager.downloadAllFiles();
    } else {
        console.error('FileManager not initialized');
    }
};

// Replace global generatePDFReport function
window.generatePDFReport = function() {
    if (fileManager) {
        return fileManager.generatePDFReport();
    } else {
        console.error('FileManager not initialized');
    }
};

// Replace global resetAllData function
window.resetAllData = function() {
    if (fileManager) {
        return fileManager.resetAllData();
    } else {
        console.error('FileManager not initialized');
    }
};

// Export FileManager integration functions
window.FileManagerIntegration = {
    initialize: initializeFileManager,
    getManager: () => fileManager
};
